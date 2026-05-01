-- Atomic couple-creation function.
-- Runs with security definer so RLS on individual tables doesn't block it.
-- Called from the client via db.rpc('create_couple', {...}).

create or replace function public.create_couple(
  p_bf_name    text,
  p_gf_name    text,
  p_gf_nickname text default null,
  p_started_on  date  default null
)
returns table (
  couple_id   uuid,
  invite_code text
)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_couple_id   uuid;
  v_invite_code text;
begin
  if auth.uid() is null then
    raise exception 'Authentication required';
  end if;

  -- 1. Create / update boyfriend profile
  insert into public.profiles (id, display_name)
  values (auth.uid(), p_bf_name)
  on conflict (id) do update
    set display_name = excluded.display_name,
        updated_at   = now();

  -- 2. Create couple
  insert into public.couples (created_by, started_on, girlfriend_label)
  values (auth.uid(), p_started_on, coalesce(p_gf_nickname, p_gf_name))
  returning id into v_couple_id;

  -- 3. Add boyfriend as member
  insert into public.couple_members (couple_id, user_id, role)
  values (v_couple_id, auth.uid(), 'boyfriend')
  on conflict (couple_id, user_id) do nothing;

  -- 4. Generate unique invite code and create invite
  v_invite_code := public.create_invite_code();

  insert into public.couple_invites (
    couple_id, created_by, invite_code,
    intended_role, intended_display_name, intended_nickname
  )
  values (
    v_couple_id, auth.uid(), v_invite_code,
    'girlfriend', p_gf_name, p_gf_nickname
  );

  return query select v_couple_id, v_invite_code;
end;
$$;
