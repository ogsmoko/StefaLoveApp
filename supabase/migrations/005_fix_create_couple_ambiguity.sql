-- Hot-fix for create_couple originally shipped in 003.
-- The OUT column `couple_id` clashed with the `couple_id` column of
-- `couple_members` inside `on conflict (couple_id, user_id)`, raising
-- "column reference 'couple_id' is ambiguous". Rename OUT columns.
--
-- Run once in Supabase SQL Editor.
-- Postgres does not allow CREATE OR REPLACE to change OUT column names,
-- so we drop the existing function first.

drop function if exists public.create_couple(text, text, text, date);

create function public.create_couple(
  p_bf_name    text,
  p_gf_name    text,
  p_gf_nickname text default null,
  p_started_on  date  default null
)
returns table (
  out_couple_id   uuid,
  out_invite_code text
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

  insert into public.profiles (id, display_name)
  values (auth.uid(), p_bf_name)
  on conflict (id) do update
    set display_name = excluded.display_name,
        updated_at   = now();

  insert into public.couples (created_by, started_on, girlfriend_label)
  values (auth.uid(), p_started_on, coalesce(p_gf_nickname, p_gf_name))
  returning id into v_couple_id;

  insert into public.couple_members (couple_id, user_id, role)
  values (v_couple_id, auth.uid(), 'boyfriend')
  on conflict (couple_id, user_id) do nothing;

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
