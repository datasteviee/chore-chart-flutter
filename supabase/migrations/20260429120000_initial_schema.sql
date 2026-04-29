-- Chore Chart initial schema (PRD §7–8) + RLS
-- Requires: pgcrypto for gen_random_uuid (enabled by default on Supabase)

create extension if not exists "pgcrypto";

-- —— families ——
create table if not exists public.families (
  id uuid primary key default gen_random_uuid(),
  name text not null default 'My Family',
  invite_code text unique,
  created_by uuid references auth.users (id) on delete set null,
  created_at timestamptz not null default now()
);

create table if not exists public.members (
  id uuid primary key default gen_random_uuid(),
  family_id uuid not null references public.families (id) on delete cascade,
  user_id uuid references auth.users (id) on delete set null,
  name text not null,
  avatar_url text,
  birth_year int,
  role text not null default 'child' check (role in ('parent', 'teen', 'child', 'guest')),
  color text,
  created_at timestamptz not null default now()
);

create table if not exists public.task_templates (
  id uuid primary key default gen_random_uuid(),
  family_id uuid not null references public.families (id) on delete cascade,
  title text not null,
  description text,
  min_age int not null default 0,
  max_age int not null default 99,
  estimated_minutes int,
  points int not null default 5,
  recurrence text not null default 'weekly' check (recurrence in ('daily', 'weekly', 'biweekly', 'monthly')),
  icon text,
  created_at timestamptz not null default now()
);

create table if not exists public.assignments (
  id uuid primary key default gen_random_uuid(),
  family_id uuid not null references public.families (id) on delete cascade,
  template_id uuid not null references public.task_templates (id) on delete cascade,
  member_id uuid not null references public.members (id) on delete cascade,
  due_date date not null,
  status text not null default 'pending' check (status in ('pending', 'done', 'skipped', 'overdue')),
  completed_at timestamptz,
  completed_by uuid references public.members (id),
  notes text,
  points_earned int not null default 0,
  created_at timestamptz not null default now()
);

create table if not exists public.streaks (
  id uuid primary key default gen_random_uuid(),
  member_id uuid not null references public.members (id) on delete cascade,
  current_streak int not null default 0,
  longest_streak int not null default 0,
  total_points int not null default 0,
  last_activity_date date,
  updated_at timestamptz not null default now(),
  unique (member_id)
);

create table if not exists public.rotation_log (
  id uuid primary key default gen_random_uuid(),
  family_id uuid not null references public.families (id) on delete cascade,
  template_id uuid references public.task_templates (id) on delete set null,
  from_member_id uuid references public.members (id) on delete set null,
  to_member_id uuid references public.members (id) on delete set null,
  week_start date not null,
  reason text not null default 'auto_rotation',
  created_at timestamptz not null default now()
);

create table if not exists public.devices (
  id uuid primary key default gen_random_uuid(),
  family_id uuid not null references public.families (id) on delete cascade,
  device_token uuid not null unique,
  member_id uuid references public.members (id) on delete set null,
  label text,
  created_at timestamptz not null default now()
);

create table if not exists public.family_subscriptions (
  id uuid primary key default gen_random_uuid(),
  family_id uuid not null references public.families (id) on delete cascade,
  provider text not null default 'revenuecat',
  external_id text,
  expires_at timestamptz,
  created_at timestamptz not null default now()
);

create index if not exists idx_members_family on public.members (family_id);
create index if not exists idx_members_user on public.members (user_id);
create index if not exists idx_task_templates_family on public.task_templates (family_id);
create index if not exists idx_assignments_family on public.assignments (family_id);
create index if not exists idx_assignments_due on public.assignments (due_date);
create index if not exists idx_devices_family on public.devices (family_id);

-- —— RLS ——
alter table public.families enable row level security;
alter table public.members enable row level security;
alter table public.task_templates enable row level security;
alter table public.assignments enable row level security;
alter table public.streaks enable row level security;
alter table public.rotation_log enable row level security;
alter table public.devices enable row level security;
alter table public.family_subscriptions enable row level security;

-- families
create policy families_select on public.families
  for select to authenticated using (
    created_by = (select auth.uid())
    or exists (
      select 1 from public.members m
      where m.family_id = families.id and m.user_id = (select auth.uid())
    )
  );

create policy families_insert on public.families
  for insert to authenticated with check (created_by = (select auth.uid()));

create policy families_update on public.families
  for update to authenticated using (
    created_by = (select auth.uid())
    or exists (
      select 1 from public.members m
      where m.family_id = families.id and m.user_id = (select auth.uid()) and m.role = 'parent'
    )
  );

create policy families_delete on public.families
  for delete to authenticated using (created_by = (select auth.uid()));

-- members
create policy members_select on public.members
  for select to authenticated using (
    user_id = (select auth.uid())
    or exists (
      select 1 from public.members m
      where m.family_id = members.family_id and m.user_id = (select auth.uid())
    )
  );

create policy members_insert on public.members
  for insert to authenticated with check (
    user_id = (select auth.uid())
    and exists (
      select 1 from public.families f
      where f.id = members.family_id
        and (f.created_by = (select auth.uid()) or exists (
          select 1 from public.members m
          where m.family_id = f.id and m.user_id = (select auth.uid()) and m.role = 'parent'
        ))
    )
  );

create policy members_update on public.members
  for update to authenticated using (
    exists (
      select 1 from public.members m
      where m.family_id = members.family_id and m.user_id = (select auth.uid())
    )
  );

create policy members_delete on public.members
  for delete to authenticated using (
    exists (
      select 1 from public.members m
      where m.family_id = members.family_id and m.user_id = (select auth.uid()) and m.role = 'parent'
    )
  );

-- templates / assignments / streaks / rotation_log / devices / family_subscriptions: same family membership
create policy task_templates_all on public.task_templates
  for all to authenticated using (
    exists (select 1 from public.members m where m.family_id = task_templates.family_id and m.user_id = (select auth.uid()))
  ) with check (
    exists (select 1 from public.members m where m.family_id = task_templates.family_id and m.user_id = (select auth.uid()))
  );

create policy assignments_all on public.assignments
  for all to authenticated using (
    exists (select 1 from public.members m where m.family_id = assignments.family_id and m.user_id = (select auth.uid()))
  ) with check (
    exists (select 1 from public.members m where m.family_id = assignments.family_id and m.user_id = (select auth.uid()))
  );

create policy streaks_all on public.streaks
  for all to authenticated using (
    exists (
      select 1 from public.members me
      join public.members m on m.family_id = me.family_id
      where me.id = streaks.member_id and m.user_id = (select auth.uid())
    )
  ) with check (
    exists (
      select 1 from public.members me
      join public.members m on m.family_id = me.family_id
      where me.id = streaks.member_id and m.user_id = (select auth.uid())
    )
  );

create policy rotation_log_all on public.rotation_log
  for all to authenticated using (
    exists (select 1 from public.members m where m.family_id = rotation_log.family_id and m.user_id = (select auth.uid()))
  ) with check (
    exists (select 1 from public.members m where m.family_id = rotation_log.family_id and m.user_id = (select auth.uid()))
  );

create policy devices_all on public.devices
  for all to authenticated using (
    exists (select 1 from public.members m where m.family_id = devices.family_id and m.user_id = (select auth.uid()))
  ) with check (
    exists (select 1 from public.members m where m.family_id = devices.family_id and m.user_id = (select auth.uid()))
  );

create policy family_subscriptions_all on public.family_subscriptions
  for all to authenticated using (
    exists (select 1 from public.members m where m.family_id = family_subscriptions.family_id and m.user_id = (select auth.uid()))
  ) with check (
    exists (select 1 from public.members m where m.family_id = family_subscriptions.family_id and m.user_id = (select auth.uid()))
  );
