-- Self-join per Einladungscode: normale members_insert-Policy erlaubt nur Ersteller/Eltern.
create or replace function public.join_family_by_invite(p_invite_code text)
returns uuid
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_family_id uuid;
  v_name text;
begin
  select f.id into v_family_id
  from public.families f
  where lower(trim(f.invite_code)) = lower(trim(p_invite_code))
  limit 1;

  if v_family_id is null then
    raise exception 'invalid_invite' using errcode = 'P0001';
  end if;

  if exists (
    select 1 from public.members m
    where m.family_id = v_family_id and m.user_id = (select auth.uid())
  ) then
    return v_family_id;
  end if;

  v_name := split_part(coalesce(auth.jwt() ->> 'email', 'user'), '@', 1);
  if v_name is null or length(trim(v_name)) = 0 then
    v_name := 'Mitglied';
  end if;

  insert into public.members (family_id, user_id, name, role)
  values (v_family_id, (select auth.uid()), v_name, 'teen');

  return v_family_id;
end;
$$;

revoke all on function public.join_family_by_invite(text) from public;
revoke execute on function public.join_family_by_invite(text) from anon;
grant execute on function public.join_family_by_invite(text) to authenticated;
