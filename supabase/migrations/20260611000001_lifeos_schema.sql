-- Tasks table
create table if not exists public.tasks (
  id text primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  title text not null,
  scheduled_at bigint not null,
  category text not null,
  is_completed boolean not null default false,
  repeats boolean not null default false,
  notes text,
  created_at timestamptz default now()
);

-- Expenses table
create table if not exists public.expenses (
  id text primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  amount numeric not null,
  category text not null,
  date bigint not null,
  notes text,
  created_at timestamptz default now()
);

-- Profiles table
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  name text not null default '',
  phone text not null default '',
  bio text not null default '',
  updated_at timestamptz default now()
);

-- Indexes
create index if not exists idx_tasks_user_id on public.tasks(user_id);
create index if not exists idx_tasks_scheduled_at on public.tasks(scheduled_at);
create index if not exists idx_expenses_user_id on public.expenses(user_id);
create index if not exists idx_expenses_date on public.expenses(date);

-- Enable RLS
alter table public.tasks enable row level security;
alter table public.expenses enable row level security;
alter table public.profiles enable row level security;

-- RLS Policies
create policy "users_own_tasks" on public.tasks
  for all using (auth.uid() = user_id);

create policy "users_own_expenses" on public.expenses
  for all using (auth.uid() = user_id);

create policy "users_own_profile" on public.profiles
  for all using (auth.uid() = id);

-- Auto-create profile on signup
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, name)
  values (new.id, coalesce(new.raw_user_meta_data->>'name', ''))
  on conflict (id) do nothing;
  return new;
end;
$$ language plpgsql security definer;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();
