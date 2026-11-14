-- TAVERINN PHASE 2 MIGRATION
-- Prerequisite: Phase 1 is already installed with the party tables, columns,
-- policies, Realtime publication, and RPC signatures in supabase/schema.sql.
-- Run this file as a single script in Supabase SQL Editor.
-- This migration does not change Phase 1 Realtime or the other Phase 1 RPCs.

begin;

-- PHASE 2 - SOCIAL PROFILE, FOLLOWING & ACTIVITY STATISTICS
-- These rows belong to user profiles and are not cascaded from party deletion.
create table if not exists public.follows (
  follower_id uuid not null references public.profiles(id) on delete cascade,
  following_id uuid not null references public.profiles(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (follower_id, following_id),
  constraint follows_no_self_follow check (follower_id <> following_id)
);

-- The primary key indexes follower_id; this index supports follower-list lookup.
create index if not exists follows_following_id_idx
  on public.follows (following_id);

create table if not exists public.user_stats (
  user_id uuid primary key references public.profiles(id) on delete cascade,
  parties_created integer not null default 0 check (parties_created >= 0),
  parties_joined integer not null default 0 check (parties_joined >= 0),
  players_met integer not null default 0 check (players_met >= 0),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- One permanent row per host/player pair. Party deletion does not remove it.
create table if not exists public.user_player_interactions (
  user_id uuid not null references public.profiles(id) on delete cascade,
  other_user_id uuid not null references public.profiles(id) on delete cascade,
  first_met_at timestamptz not null default now(),
  primary key (user_id, other_user_id),
  constraint user_player_interactions_no_self check (user_id <> other_user_id)
);

create index if not exists user_player_interactions_other_user_id_idx
  on public.user_player_interactions (other_user_id);

-- Create stats whenever a profile is created, including profiles made by the
-- existing auth.users trigger. Keep handle_new_user() unchanged.
create or replace function public.handle_new_profile_stats()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.user_stats (user_id)
  values (new.id)
  on conflict (user_id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_profile_created_stats on public.profiles;
create trigger on_profile_created_stats
after insert on public.profiles
for each row execute procedure public.handle_new_profile_stats();

-- Backfill profiles created before Phase 2 without overwriting existing stats.
insert into public.user_stats (user_id)
select p.id from public.profiles p
on conflict (user_id) do nothing;

-- Preserve unique-player statistics for parties that are active at migration
-- time. The interaction primary key makes this backfill idempotent.
with inserted_interactions as (
  insert into public.user_player_interactions (user_id, other_user_id)
  select distinct p.user_id, pm.user_id
  from public.lfg_posts p
  join public.party_members pm on pm.post_id = p.id
  where pm.user_id <> p.user_id
  on conflict (user_id, other_user_id) do nothing
  returning user_id
), new_interaction_counts as (
  select user_id, count(*)::integer as added
  from inserted_interactions
  group by user_id
)
update public.user_stats s
set players_met = s.players_met + counts.added,
    updated_at = now()
from new_interaction_counts counts
where s.user_id = counts.user_id;

-- =========================

-- =========================
-- FOLLOW RPCs
-- =========================
create or replace function public.follow_user(target_user_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  uid uuid := auth.uid();
begin
  if uid is null then
    raise exception 'Not authenticated';
  end if;
  if target_user_id = uid then
    raise exception 'Cannot follow yourself';
  end if;
  if not exists (
    select 1 from public.profiles p where p.id = target_user_id
  ) then
    raise exception 'Profile not found';
  end if;

  insert into public.follows (follower_id, following_id)
  values (uid, target_user_id)
  on conflict (follower_id, following_id) do nothing;
end;
$$;

create or replace function public.unfollow_user(target_user_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  uid uuid := auth.uid();
begin
  if uid is null then
    raise exception 'Not authenticated';
  end if;
  if target_user_id = uid then
    raise exception 'Cannot unfollow yourself';
  end if;

  delete from public.follows
  where follower_id = uid and following_id = target_user_id;
end;
$$;

revoke all on function public.follow_user(uuid) from public;
revoke all on function public.unfollow_user(uuid) from public;
grant execute on function public.follow_user(uuid) to authenticated;
grant execute on function public.unfollow_user(uuid) to authenticated;

-- =========================
-- PARTY STAT COUNTERS
-- =========================
-- Replaces only the existing create/join RPC bodies, preserving names and
-- signatures while adding transactional counters and unique Players Met.
-- JOIN PARTY RPC
-- Atomic transaction:
-- checks capacity, inserts member, increments player count.
-- =========================
create or replace function public.join_lfg_party(target_post_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  uid uuid := auth.uid();
  post_row public.lfg_posts%rowtype;
begin
  if uid is null then
    raise exception 'Not authenticated';
  end if;

  select *
  into post_row
  from public.lfg_posts
  where id = target_post_id
  for update;

  if not found then
    raise exception 'Party not found';
  end if;

  if post_row.status <> 'open' then
    raise exception 'Party is not open';
  end if;

  if exists (
    select 1 from public.party_members
    where post_id = target_post_id and user_id = uid
  ) then
    raise exception 'Already joined';
  end if;

  if post_row.current_players >= post_row.max_players then
    raise exception 'Party is full';
  end if;

  insert into public.party_members(post_id, user_id)
  values(target_post_id, uid);

  insert into public.user_stats (user_id, parties_joined)
  values (uid, 1)
  on conflict (user_id) do update
  set parties_joined = public.user_stats.parties_joined + 1,
      updated_at = now();

  if uid <> post_row.user_id then
    insert into public.user_player_interactions (user_id, other_user_id)
    values (post_row.user_id, uid)
    on conflict (user_id, other_user_id) do nothing;

    if found then
      insert into public.user_stats (user_id, players_met)
      values (post_row.user_id, 1)
      on conflict (user_id) do update
      set players_met = public.user_stats.players_met + 1,
          updated_at = now();
    end if;
  end if;

  update public.lfg_posts
  set
    current_players = current_players + 1,
    status = case
      when current_players + 1 >= max_players then 'full'
      else 'open'
    end
  where id = target_post_id;
end;
$$;

-- CREATE PARTY RPC: creates the post and host membership atomically.
create or replace function public.create_lfg_party(
  target_game_id uuid,
  target_mode text,
  target_rank text,
  target_language text,
  target_max_players integer,
  target_play_time text,
  target_description text
)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  uid uuid := auth.uid();
  new_post_id uuid;
begin
  if uid is null then
    raise exception 'Not authenticated';
  end if;

  insert into public.lfg_posts (
    user_id, game_id, mode, rank, language, current_players,
    max_players, play_time, description, status
  ) values (
    uid, target_game_id, target_mode, target_rank, target_language, 1,
    target_max_players, target_play_time, target_description, 'open'
  ) returning id into new_post_id;

  insert into public.party_members (post_id, user_id)
  values (new_post_id, uid);

  insert into public.user_stats (user_id, parties_created)
  values (uid, 1)
  on conflict (user_id) do update
  set parties_created = public.user_stats.parties_created + 1,
      updated_at = now();

  return new_post_id;
end;
$$;

revoke all on function public.create_lfg_party(uuid, text, text, text, integer, text, text) from public;
revoke all on function public.join_lfg_party(uuid) from public;
grant execute on function public.create_lfg_party(uuid, text, text, text, integer, text, text) to authenticated;
grant execute on function public.join_lfg_party(uuid) to authenticated;

-- =========================
-- PHASE 2 RLS
-- =========================
alter table public.follows enable row level security;
alter table public.user_stats enable row level security;
alter table public.user_player_interactions enable row level security;

do $$
begin
  if not exists (
    select 1 from pg_policies
    where schemaname = 'public' and tablename = 'follows'
      and policyname = 'follows_select_authenticated'
  ) then
    execute 'create policy follows_select_authenticated on public.follows for select to authenticated using (true)';
  end if;
  if not exists (
    select 1 from pg_policies
    where schemaname = 'public' and tablename = 'user_stats'
      and policyname = 'user_stats_select_authenticated'
  ) then
    execute 'create policy user_stats_select_authenticated on public.user_stats for select to authenticated using (true)';
  end if;
end;
$$;

-- Approved Phase 2 visibility: all authenticated users can read game dashboards.
-- Preserve the existing own-only INSERT/UPDATE/DELETE policies.
drop policy if exists "user_games_select_own" on public.user_games;
drop policy if exists "user_games_select_authenticated" on public.user_games;
create policy "user_games_select_authenticated"
on public.user_games for select
to authenticated
using (true);

-- user_player_interactions intentionally has no client policy; the join RPC
-- writes it under SECURITY DEFINER and clients cannot read it.

commit;
