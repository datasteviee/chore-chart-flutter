-- Lint 0028: SECURITY DEFINER helpers must not be callable with the anonymous key.
-- RLS still invokes them internally; only EXECUTE for `authenticated` is required.

revoke execute on function public.auth_member_family_ids() from anon;
revoke execute on function public.auth_is_member_of_family(uuid) from anon;
revoke execute on function public.auth_is_parent_in_family(uuid) from anon;
revoke execute on function public.auth_member_row_family_id(uuid) from anon;
