-- Fix 42P17: infinite recursion in RLS on "members".
-- Policies must not query `members` directly (same table) without bypassing RLS.
-- SECURITY DEFINER + table owner bypasses RLS for the inner read.
-- Use (select auth.uid()) in policies / helpers so auth.* is not re-evaluated per row (Supabase advisor).

create or replace function public.auth_member_family_ids()
returns setof uuid
language sql
stable
security definer
set search_path = public
as $$
  select m.family_id from public.members m where m.user_id = (select auth.uid());
$$;

create or replace function public.auth_is_member_of_family(p_family_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.members m
    where m.family_id = p_family_id and m.user_id = (select auth.uid())
  );
$$;

create or replace function public.auth_is_parent_in_family(p_family_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.members m
    where m.family_id = p_family_id and m.user_id = (select auth.uid()) and m.role = 'parent'
  );
$$;

create or replace function public.auth_member_row_family_id(p_member_id uuid)
returns uuid
language sql
stable
security definer
set search_path = public
as $$
  select family_id from public.members where id = p_member_id;
$$;

revoke all on function public.auth_member_family_ids() FROM PUBLIC;
revoke all on function public.auth_is_member_of_family(uuid) FROM PUBLIC;
revoke all on function public.auth_is_parent_in_family(uuid) FROM PUBLIC;
revoke all on function public.auth_member_row_family_id(uuid) FROM PUBLIC;

grant execute on function public.auth_member_family_ids() to authenticated;
grant execute on function public.auth_is_member_of_family(uuid) to authenticated;
grant execute on function public.auth_is_parent_in_family(uuid) to authenticated;
grant execute on function public.auth_member_row_family_id(uuid) to authenticated;

-- —— Drop policies that recurse through members ——

drop policy if exists families_select on public.families;
drop policy if exists families_insert on public.families;
drop policy if exists families_update on public.families;
drop policy if exists families_delete on public.families;
drop policy if exists members_select on public.members;
drop policy if exists members_insert on public.members;
drop policy if exists members_update on public.members;
drop policy if exists members_delete on public.members;
drop policy if exists task_templates_all on public.task_templates;
drop policy if exists assignments_all on public.assignments;
drop policy if exists streaks_all on public.streaks;
drop policy if exists rotation_log_all on public.rotation_log;
drop policy if exists devices_all on public.devices;
drop policy if exists family_subscriptions_all on public.family_subscriptions;

-- —— families ——

create policy families_select on public.families
  for select to authenticated using (
    created_by = (select auth.uid())
    or id in (select public.auth_member_family_ids())
  );

create policy families_update on public.families
  for update to authenticated using (
    created_by = (select auth.uid())
    or public.auth_is_parent_in_family(id)
  );

create policy families_insert on public.families
  for insert to authenticated with check (created_by = (select auth.uid()));

create policy families_delete on public.families
  for delete to authenticated using (created_by = (select auth.uid()));

-- —— members ——

create policy members_select on public.members
  for select to authenticated using (
    user_id = (select auth.uid())
    or public.auth_is_member_of_family(family_id)
  );

create policy members_insert on public.members
  for insert to authenticated with check (
    user_id = (select auth.uid())
    and (
      exists (
        select 1 from public.families f
        where f.id = members.family_id and f.created_by = (select auth.uid())
      )
      or public.auth_is_parent_in_family(members.family_id)
    )
  );

create policy members_update on public.members
  for update to authenticated using (
    public.auth_is_member_of_family(family_id)
  );

create policy members_delete on public.members
  for delete to authenticated using (
    public.auth_is_parent_in_family(family_id)
  );

-- —— Other tables (same membership check, no direct members subquery in policy) ——

create policy task_templates_all on public.task_templates
  for all to authenticated using (
    public.auth_is_member_of_family(task_templates.family_id)
  ) with check (
    public.auth_is_member_of_family(task_templates.family_id)
  );

create policy assignments_all on public.assignments
  for all to authenticated using (
    public.auth_is_member_of_family(assignments.family_id)
  ) with check (
    public.auth_is_member_of_family(assignments.family_id)
  );

create policy streaks_all on public.streaks
  for all to authenticated using (
    public.auth_is_member_of_family(public.auth_member_row_family_id(streaks.member_id))
  ) with check (
    public.auth_is_member_of_family(public.auth_member_row_family_id(streaks.member_id))
  );

create policy rotation_log_all on public.rotation_log
  for all to authenticated using (
    public.auth_is_member_of_family(rotation_log.family_id)
  ) with check (
    public.auth_is_member_of_family(rotation_log.family_id)
  );

create policy devices_all on public.devices
  for all to authenticated using (
    public.auth_is_member_of_family(devices.family_id)
  ) with check (
    public.auth_is_member_of_family(devices.family_id)
  );

create policy family_subscriptions_all on public.family_subscriptions
  for all to authenticated using (
    public.auth_is_member_of_family(family_subscriptions.family_id)
  ) with check (
    public.auth_is_member_of_family(family_subscriptions.family_id)
  );
