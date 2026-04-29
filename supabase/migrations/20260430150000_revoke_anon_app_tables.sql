-- Supabase security: do not expose family data to the anonymous API key (anon).
-- PostgREST / GraphQL must not allow anon SELECT on these tables; the Flutter
-- app uses only the authenticated session + RLS.

revoke all on table public.families from anon;
revoke all on table public.members from anon;
revoke all on table public.task_templates from anon;
revoke all on table public.assignments from anon;
revoke all on table public.streaks from anon;
revoke all on table public.rotation_log from anon;
revoke all on table public.devices from anon;
revoke all on table public.family_subscriptions from anon;
