-- Covering indexes for foreign keys (Supabase performance linter 0001).

create index if not exists idx_assignments_template_id on public.assignments (template_id);
create index if not exists idx_assignments_member_id on public.assignments (member_id);
create index if not exists idx_assignments_completed_by on public.assignments (completed_by);

create index if not exists idx_devices_member_id on public.devices (member_id);

create index if not exists idx_families_created_by on public.families (created_by);

create index if not exists idx_family_subscriptions_family_id on public.family_subscriptions (family_id);

create index if not exists idx_rotation_log_family_id on public.rotation_log (family_id);
create index if not exists idx_rotation_log_template_id on public.rotation_log (template_id);
create index if not exists idx_rotation_log_from_member_id on public.rotation_log (from_member_id);
create index if not exists idx_rotation_log_to_member_id on public.rotation_log (to_member_id);
