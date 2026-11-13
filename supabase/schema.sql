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
create policy "user_games_select_own"
on public.user_games for select
to authenticated
using (user_id = auth.uid());

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

drop policy if exists "lfg_insert_own" on public.lfg_posts;
create policy "lfg_insert_own"
on public.lfg_posts for insert
to authenticated
with check (user_id = auth.uid());

drop policy if exists "lfg_update_own" on public.lfg_posts;
create policy "lfg_update_own"
on public.lfg_posts for update
to authenticated
using (user_id = auth.uid())
with check (user_id = auth.uid());

drop policy if exists "lfg_delete_own" on public.lfg_posts;
create policy "lfg_delete_own"
on public.lfg_posts for delete
to authenticated
using (user_id = auth.uid());

-- PARTY MEMBERS
drop policy if exists "party_members_select_authenticated" on public.party_members;
create policy "party_members_select_authenticated"
on public.party_members for select
to authenticated
using (true);

drop policy if exists "party_members_insert_self" on public.party_members;
create policy "party_members_insert_self"
on public.party_members for insert
to authenticated
with check (user_id = auth.uid());

-- Note:
-- Joining should normally use join_lfg_party() RPC rather than direct insert.
