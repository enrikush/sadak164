-- ============================================================
-- Personnel management schema for קורס מפקדים 164
-- Run this once in the Supabase SQL editor (Project -> SQL Editor -> New query)
-- ============================================================

create extension if not exists "pgcrypto";

-- Soldiers -----------------------------------------------------
create table if not exists soldiers (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  team text not null,
  phone text,
  status text not null default 'בבסיס',
  created_at timestamptz not null default now()
);

-- Tasks ----------------------------------------------------------
create table if not exists tasks (
  id uuid primary key default gen_random_uuid(),
  group_id uuid,
  title text not null,
  description text,
  due_date date,
  due_time time,
  priority text not null default 'רגיל',
  assigned_to uuid references soldiers(id) on delete cascade,
  status text not null default 'פתוח',
  created_at timestamptz not null default now(),
  completed_at timestamptz
);

-- Daily schedule ---------------------------------------------------
create table if not exists schedule_items (
  id uuid primary key default gen_random_uuid(),
  time text not null,
  title text not null,
  note text,
  created_at timestamptz not null default now()
);

-- Guard duty (single active board) -------------------------------
create table if not exists guard_settings (
  id int primary key default 1,
  date date not null default current_date,
  constraint guard_settings_single_row check (id = 1)
);
insert into guard_settings (id, date)
  values (1, current_date)
  on conflict (id) do nothing;

create table if not exists guard_posts (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  created_at timestamptz not null default now()
);

create table if not exists guard_slots (
  id uuid primary key default gen_random_uuid(),
  label text not null,
  created_at timestamptz not null default now()
);

create table if not exists guard_assignments (
  slot_id uuid not null references guard_slots(id) on delete cascade,
  post_id uuid not null references guard_posts(id) on delete cascade,
  soldier_id uuid not null references soldiers(id) on delete cascade,
  primary key (slot_id, post_id)
);

-- Lessons learned ("לקחים") ---------------------------------------
create table if not exists lessons (
  id uuid primary key default gen_random_uuid(),
  author_id uuid references soldiers(id) on delete set null,
  author_name text,
  set_label text,
  text text not null,
  created_at timestamptz not null default now()
);

-- ============================================================
-- Row Level Security
--
-- This app has no real user accounts (soldiers just pick their name
-- from a list). To keep things simple, RLS is enabled with a single
-- permissive policy per table so the app's anon key can read/write
-- everything. This is fine for an internal tool shared over a private
-- link, but do NOT use this schema for sensitive data on a public URL
-- without adding real authentication.
-- ============================================================

alter table soldiers enable row level security;
alter table tasks enable row level security;
alter table schedule_items enable row level security;
alter table guard_settings enable row level security;
alter table guard_posts enable row level security;
alter table guard_slots enable row level security;
alter table guard_assignments enable row level security;
alter table lessons enable row level security;

drop policy if exists "allow all" on soldiers;
drop policy if exists "allow all" on tasks;
drop policy if exists "allow all" on schedule_items;
drop policy if exists "allow all" on guard_settings;
drop policy if exists "allow all" on guard_posts;
drop policy if exists "allow all" on guard_slots;
drop policy if exists "allow all" on guard_assignments;
drop policy if exists "allow all" on lessons;

create policy "allow all" on soldiers for all using (true) with check (true);
create policy "allow all" on tasks for all using (true) with check (true);
create policy "allow all" on schedule_items for all using (true) with check (true);
create policy "allow all" on guard_settings for all using (true) with check (true);
create policy "allow all" on guard_posts for all using (true) with check (true);
create policy "allow all" on guard_slots for all using (true) with check (true);
create policy "allow all" on guard_assignments for all using (true) with check (true);
create policy "allow all" on lessons for all using (true) with check (true);
