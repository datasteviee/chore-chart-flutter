-- Lint 0029: SECURITY DEFINER helpers in `public` are exposed as PostgREST RPC.
-- Move them to `chore_private` (not listed under API → Exposed schemas by default),
-- so they are only used from RLS expressions, not as public RPC.
--
-- Lint 0027 (GraphQL + authenticated SELECT on public tables): unchanged by this migration.
-- If you do not use GraphQL: Dashboard → Settings → API → disable GraphQL to clear those 8 warnings.
-- RLS still enforces row access for REST/Flutter.

create schema if not exists chore_private;

revoke all on schema chore_private from public;
grant usage on schema chore_private to authenticated;

create or replace function chore_private.auth_member_family_ids()
returns setof uuid
language sql
stable
security definer
set search_path = public, pg_temp
as $$
  select m.family_id from public.members m where m.user_id = (select auth.uid());
$$;

create or replace function chore_private.auth_is_member_of_family(p_family_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public, pg_temp
as $$
  select exists (
    select 1 from public.members m
    where m.family_id = p_family_id and m.user_id = (select auth.uid())
  );
$$;

create or replace function chore_private.auth_is_parent_in_family(p_family_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public, pg_temp
as $$
  select exists (
    select 1 from public.members m
    where m.family_id = p_family_id and m.user_id = (select auth.uid()) and m.role = 'parent'
  );
$$;

create or replace function chore_private.auth_member_row_family_id(p_member_id uuid)
returns uuid
language sql
stable
security definer
set search_path = public, pg_temp
as $$
  select family_id from public.members where id = p_member_id;
$$;

revoke all on function chore_private.auth_member_family_ids() from public;
revoke all on function chore_private.auth_is_member_of_family(uuid) from public;
revoke all on function chore_private.auth_is_parent_in_family(uuid) from public;
revoke all on function chore_private.auth_member_row_family_id(uuid) from public;

grant execute on function chore_private.auth_member_family_ids() to authenticated;
grant execute on function chore_private.auth_is_member_of_family(uuid) to authenticated;
grant execute on function chore_private.auth_is_parent_in_family(uuid) to authenticated;
grant execute on function chore_private.auth_member_row_family_id(uuid) to authenticated;

-- Policies (drop → drop old public helpers → recreate pointing at chore_private)

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

drop function if exists public.auth_member_family_ids();
drop function if exists public.auth_is_member_of_family(uuid);
drop function if exists public.auth_is_parent_in_family(uuid);
drop function if exists public.auth_member_row_family_id(uuid);

create policy families_select on public.families
  for select to authenticated using (
    created_by = (select auth.uid())
    or id in (select chore_private.auth_member_family_ids())
  );

create policy families_update on public.families
  for update to authenticated using (
    created_by = (select auth.uid())
    or chore_private.auth_is_parent_in_family(id)
  );

create policy families_insert on public.families
  for insert to authenticated with check (created_by = (select auth.uid()));

create policy families_delete on public.families
  for delete to authenticated using (created_by = (select auth.uid()));

create policy members_select on public.members
  for select to authenticated using (
    user_id = (select auth.uid())
    or chore_private.auth_is_member_of_family(family_id)
  );

create policy members_insert on public.members
  for insert to authenticated with check (
    user_id = (select auth.uid())
    and (
      exists (
        select 1 from public.families f
        where f.id = members.family_id and f.created_by = (select auth.uid())
      )
      or chore_private.auth_is_parent_in_family(members.family_id)
    )
  );

create policy members_update on public.members
  for update to authenticated using (
    chore_private.auth_is_member_of_family(family_id)
  );

create policy members_delete on public.members
  for delete to authenticated using (
    chore_private.auth_is_parent_in_family(family_id)
  );

create policy task_templates_all on public.task_templates
  for all to authenticated using (
    chore_private.auth_is_member_of_family(task_templates.family_id)
  ) with check (
    chore_private.auth_is_member_of_family(task_templates.family_id)
  );

create policy assignments_all on public.assignments
  for all to authenticated using (
    chore_private.auth_is_member_of_family(assignments.family_id)
  ) with check (
    chore_private.auth_is_member_of_family(assignments.family_id)
  );

create policy streaks_all on public.streaks
  for all to authenticated using (
    chore_private.auth_is_member_of_family(chore_private.auth_member_row_family_id(streaks.member_id))
  ) with check (
    chore_private.auth_is_member_of_family(chore_private.auth_member_row_family_id(streaks.member_id))
  );

create policy rotation_log_all on public.rotation_log
  for all to authenticated using (
    chore_private.auth_is_member_of_family(rotation_log.family_id)
  ) with check (
    chore_private.auth_is_member_of_family(rotation_log.family_id)
  );

create policy devices_all on public.devices
  for all to authenticated using (
    chore_private.auth_is_member_of_family(devices.family_id)
  ) with check (
    chore_private.auth_is_member_of_family(devices.family_id)
  );

create policy family_subscriptions_all on public.family_subscriptions
  for all to authenticated using (
    chore_private.auth_is_member_of_family(family_subscriptions.family_id)
  ) with check (
    chore_private.auth_is_member_of_family(family_subscriptions.family_id)
  );
