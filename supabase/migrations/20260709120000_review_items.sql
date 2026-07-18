-- Review items sync for smart revision plans

create table if not exists public.review_items (
  id text not null,
  user_id uuid not null references auth.users (id) on delete cascade,
  title text not null,
  subtitle text not null,
  priority text not null check (priority in ('high', 'medium', 'low')),
  surah_number smallint,
  ayah_start smallint,
  ayah_end smallint,
  reviewed boolean not null default false,
  difficult boolean not null default false,
  updated_at timestamptz not null default now(),
  primary key (user_id, id)
);

alter table public.review_items enable row level security;

create policy "review_items_select_own"
  on public.review_items for select
  using (auth.uid() = user_id);

create policy "review_items_insert_own"
  on public.review_items for insert
  with check (auth.uid() = user_id);

create policy "review_items_update_own"
  on public.review_items for update
  using (auth.uid() = user_id);
