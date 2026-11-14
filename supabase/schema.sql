-- TAVERINN SUPABASE SCHEMA
-- Jalankan script ini di Supabase Dashboard > SQL Editor.

create extension if not exists pgcrypto;

-- =========================
-- PROFILES
-- =========================
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  username text not null unique,
  avatar_url text,
  created_at timestamptz not null default now()
);

-- =========================
-- GAMES
-- =========================
create table if not exists public.games (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  icon_url text,
  created_at timestamptz not null default now()
);

-- =========================
-- USER GAMES
-- =========================
create table if not exists public.user_games (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  game_id uuid not null references public.games(id) on delete cascade,
  rank text not null,
  role text not null,
  games_played integer not null default 0 check (games_played >= 0),
  win_rate numeric(5,2) not null default 0 check (win_rate >= 0 and win_rate <= 100),
  favorite_character text default '',
  created_at timestamptz not null default now(),
  unique(user_id, game_id)
);

-- =========================
-- LFG POSTS
-- =========================
create table if not exists public.lfg_posts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  game_id uuid not null references public.games(id) on delete restrict,
  mode text not null,
  rank text not null,
  language text not null,
  current_players integer not null default 1 check (current_players >= 1),
  max_players integer not null check (max_players >= 2 and max_players <= 20),
  play_time text not null,
  description text not null,
  status text not null default 'open' check (status in ('open', 'full', 'closed')),
  created_at timestamptz not null default now(),
  check (current_players <= max_players)
);

-- =========================
-- PARTY MEMBERS
-- =========================
create table if not exists public.party_members (
  id uuid primary key default gen_random_uuid(),
  post_id uuid not null references public.lfg_posts(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  joined_at timestamptz not null default now(),
  unique(post_id, user_id)
);

-- PHASE 1 - PARTY ROOM MIGRATION
-- Safe to rerun: adds room state/messages and replaces client access with RPCs.
-- Existing profiles, games, user_games, and party data are not deleted.
-- Party room state. Existing members start as not ready.
alter table public.party_members
  add column if not exists is_ready boolean not null default false;

-- Messages are temporary and follow the party lifecycle.
create table if not exists public.party_messages (
  id uuid primary key default gen_random_uuid(),
  post_id uuid not null references public.lfg_posts(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  message text not null check (char_length(trim(message)) between 1 and 2000),
  created_at timestamptz not null default now()
);

-- Repair any party left without its host membership by the old two-request flow.
insert into public.party_members (post_id, user_id)
select p.id, p.user_id
from public.lfg_posts p
where not exists (
  select 1
  from public.party_members pm
  where pm.post_id = p.id and pm.user_id = p.user_id
)
on conflict (post_id, user_id) do nothing;

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
-- AUTO CREATE PROFILE
-- =========================
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  desired_username text;
begin
  desired_username := coalesce(
    new.raw_user_meta_data->>'username',
    split_part(new.email, '@', 1)
  );

  insert into public.profiles (id, username)
  values (new.id, desired_username)
  on conflict (id) do nothing;

  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;

create trigger on_auth_user_created
after insert on auth.users
for each row execute procedure public.handle_new_user();

-- =========================
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

create or replace function public.set_party_ready(
  target_post_id uuid,
  target_is_ready boolean
)
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

  update public.party_members
  set is_ready = target_is_ready
  where post_id = target_post_id and user_id = uid;

  if not found then
    raise exception 'Not a party member';
  end if;
end;
$$;

create or replace function public.leave_lfg_party(target_post_id uuid)
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

  select * into post_row
  from public.lfg_posts
  where id = target_post_id
  for update;

  if not found then
    raise exception 'Party not found';
  end if;
  if post_row.user_id = uid then
    raise exception 'Host must end the party';
  end if;

  delete from public.party_members
  where post_id = target_post_id and user_id = uid;
  if not found then
    raise exception 'Not a party member';
  end if;

  update public.lfg_posts
  set current_players = current_players - 1,
      status = case when status = 'full' then 'open' else status end
  where id = target_post_id;
end;
$$;

create or replace function public.end_lfg_party(target_post_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  uid uuid := auth.uid();
  host_id uuid;
begin
  if uid is null then
    raise exception 'Not authenticated';
  end if;

  select user_id into host_id
  from public.lfg_posts
  where id = target_post_id
  for update;

  if not found then
    raise exception 'Party not found';
  end if;
  if host_id <> uid then
    raise exception 'Only the host can end this party';
  end if;

  delete from public.lfg_posts where id = target_post_id;
end;
$$;

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

revoke all on function public.create_lfg_party(uuid, text, text, text, integer, text, text) from public;
revoke all on function public.join_lfg_party(uuid) from public;
revoke all on function public.set_party_ready(uuid, boolean) from public;
revoke all on function public.leave_lfg_party(uuid) from public;
revoke all on function public.end_lfg_party(uuid) from public;
revoke all on function public.follow_user(uuid) from public;
revoke all on function public.unfollow_user(uuid) from public;
grant execute on function public.create_lfg_party(uuid, text, text, text, integer, text, text) to authenticated;
grant execute on function public.join_lfg_party(uuid) to authenticated;
grant execute on function public.set_party_ready(uuid, boolean) to authenticated;
grant execute on function public.leave_lfg_party(uuid) to authenticated;
grant execute on function public.end_lfg_party(uuid) to authenticated;
grant execute on function public.follow_user(uuid) to authenticated;
grant execute on function public.unfollow_user(uuid) to authenticated;

-- =========================
-- SEED GAMES
-- =========================
insert into public.games(name) values
  ('Valorant'),
  ('Mobile Legends'),
  ('PUBG'),
  ('Dota 2'),
  ('Minecraft'),
  ('Roblox')
on conflict (name) do nothing;

-- =========================
-- RLS
-- =========================
alter table public.profiles enable row level security;
alter table public.games enable row level security;
alter table public.user_games enable row level security;
alter table public.lfg_posts enable row level security;
alter table public.party_members enable row level security;
alter table public.party_messages enable row level security;
alter table public.follows enable row level security;
alter table public.user_stats enable row level security;
alter table public.user_player_interactions enable row level security;

-- PROFILES
drop policy if exists "profiles_select_authenticated" on public.profiles;
create policy "profiles_select_authenticated"
on public.profiles for select
to authenticated
using (true);

drop policy if exists "profiles_update_own" on public.profiles;
create policy "profiles_update_own"
on public.profiles for update
to authenticated
using (id = auth.uid())
with check (id = auth.uid());

-- GAMES
drop policy if exists "games_select_authenticated" on public.games;
create policy "games_select_authenticated"
on public.games for select
to authenticated
using (true);

-- USER GAMES
drop policy if exists "user_games_select_own" on public.user_games;
drop policy if exists "user_games_select_authenticated" on public.user_games;
create policy "user_games_select_authenticated"
on public.user_games for select
to authenticated
using (true);

drop policy if exists "user_games_insert_own" on public.user_games;
create policy "user_games_insert_own"
on public.user_games for insert
to authenticated
with check (user_id = auth.uid());

drop policy if exists "user_games_update_own" on public.user_games;
create policy "user_games_update_own"
on public.user_games for update
to authenticated
using (user_id = auth.uid())
with check (user_id = auth.uid());

drop policy if exists "user_games_delete_own" on public.user_games;
create policy "user_games_delete_own"
on public.user_games for delete
to authenticated
using (user_id = auth.uid());

-- LFG POSTS
drop policy if exists "lfg_select_authenticated" on public.lfg_posts;
create policy "lfg_select_authenticated"
on public.lfg_posts for select
to authenticated
using (true);

-- Creation and lifecycle mutations are restricted to the security-definer RPCs.
drop policy if exists "lfg_insert_own" on public.lfg_posts;

drop policy if exists "lfg_update_own" on public.lfg_posts;

drop policy if exists "lfg_delete_own" on public.lfg_posts;

-- PARTY MEMBERS
drop policy if exists "party_members_select_authenticated" on public.party_members;
create policy "party_members_select_authenticated"
on public.party_members for select
to authenticated
using (true);

drop policy if exists "party_members_insert_self" on public.party_members;
-- Membership changes are performed only by security-definer RPCs.

-- PARTY MESSAGES: members can read/send; there are no update/delete policies.
drop policy if exists "party_messages_select_members" on public.party_messages;
create policy "party_messages_select_members"
on public.party_messages for select
to authenticated
using (exists (
  select 1 from public.party_members pm
  where pm.post_id = party_messages.post_id and pm.user_id = auth.uid()
));

drop policy if exists "party_messages_insert_members" on public.party_messages;
create policy "party_messages_insert_members"
on public.party_messages for insert
to authenticated
with check (
  user_id = auth.uid()
  and exists (
    select 1 from public.party_members pm
    where pm.post_id = party_messages.post_id and pm.user_id = auth.uid()
  )
);

-- SOCIAL RELATIONSHIPS: authenticated users may view lists/counts. Writes use RPCs.
drop policy if exists "follows_select_authenticated" on public.follows;
create policy "follows_select_authenticated"
on public.follows for select
to authenticated
using (true);

drop policy if exists "follows_insert_self" on public.follows;
drop policy if exists "follows_delete_self" on public.follows;

-- Activity counters are readable on profiles but can only be changed by RPCs.
drop policy if exists "user_stats_select_authenticated" on public.user_stats;
create policy "user_stats_select_authenticated"
on public.user_stats for select
to authenticated
using (true);

drop policy if exists "user_stats_insert_self" on public.user_stats;
drop policy if exists "user_stats_update_self" on public.user_stats;
drop policy if exists "user_stats_delete_self" on public.user_stats;

-- user_player_interactions is internal durable deduplication data; no client policies.

-- Realtime publication setup; safe to rerun and adds only missing tables.
do $$
declare
  table_name text;
begin
  foreach table_name in array array['party_members', 'party_messages', 'lfg_posts'] loop
    if not exists (
      select 1 from pg_publication_tables
      where pubname = 'supabase_realtime'
        and schemaname = 'public'
        and tablename = table_name
    ) then
      execute format('alter publication supabase_realtime add table public.%I', table_name);
    end if;
  end loop;
exception when undefined_object then
  raise notice 'Publication supabase_realtime is unavailable; enable Realtime for party tables in Supabase.';
end;
$$;

-- Client membership changes must use create_lfg_party(), join_lfg_party(),
-- set_party_ready(), leave_lfg_party(), or end_lfg_party() RPCs.
