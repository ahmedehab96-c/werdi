-- Werdi addon schema for shared Supabase project (LifeOS compatible)
-- Does NOT recreate public.profiles.

create table if not exists public.user_progress (
  user_id uuid primary key references auth.users (id) on delete cascade,
  memorized_ayah_count integer not null default 0,
  reviewed_items_count integer not null default 0,
  streak_days integer not null default 0,
  last_surah_number smallint,
  last_ayah_number smallint,
  last_progress numeric(5, 2) not null default 0,
  updated_at timestamptz not null default now()
);

create table if not exists public.bookmarks (
  id bigserial primary key,
  user_id uuid not null references auth.users (id) on delete cascade,
  type text not null check (type in ('surah', 'ayah')),
  surah_number smallint not null,
  ayah_number smallint,
  preview_text text,
  created_at timestamptz not null default now(),
  unique (user_id, type, surah_number, ayah_number)
);

create table if not exists public.achievements (
  id bigserial primary key,
  user_id uuid not null references auth.users (id) on delete cascade,
  key text not null,
  title text not null,
  earned_at timestamptz not null default now(),
  unique (user_id, key)
);

alter table public.user_progress enable row level security;
alter table public.bookmarks enable row level security;
alter table public.achievements enable row level security;

create policy "werdi_user_progress_select_own"
  on public.user_progress for select
  using (auth.uid() = user_id);

create policy "werdi_user_progress_insert_own"
  on public.user_progress for insert
  with check (auth.uid() = user_id);

create policy "werdi_user_progress_update_own"
  on public.user_progress for update
  using (auth.uid() = user_id);

create policy "werdi_bookmarks_select_own"
  on public.bookmarks for select
  using (auth.uid() = user_id);

create policy "werdi_bookmarks_insert_own"
  on public.bookmarks for insert
  with check (auth.uid() = user_id);

create policy "werdi_bookmarks_delete_own"
  on public.bookmarks for delete
  using (auth.uid() = user_id);

create policy "werdi_achievements_select_own"
  on public.achievements for select
  using (auth.uid() = user_id);

create policy "werdi_achievements_insert_own"
  on public.achievements for insert
  with check (auth.uid() = user_id);

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, name)
  values (new.id, coalesce(new.raw_user_meta_data->>'name', ''))
  on conflict (id) do nothing;

  insert into public.user_progress (user_id, streak_days)
  values (new.id, 1)
  on conflict (user_id) do nothing;

  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
after insert on auth.users
for each row execute procedure public.handle_new_user();
