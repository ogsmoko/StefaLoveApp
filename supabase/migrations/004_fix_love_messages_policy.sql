-- Hot-fix for love_messages policies originally shipped in 002.
-- The previous SELECT policy had a tautological exists() that allowed every
-- authenticated user to read every row. Drop the old policies and recreate
-- them as couple-scoped.

-- Drop both old (admin) and new (partner) policy names so this script is
-- idempotent on environments that already ran the buggy 002 *and* on fresh
-- ones where 002 already created the partner policies.
drop policy if exists "love_messages_select"            on public.love_messages;
drop policy if exists "love_messages_insert_admin"      on public.love_messages;
drop policy if exists "love_messages_insert_partner"    on public.love_messages;
drop policy if exists "love_messages_update_recipient"  on public.love_messages;
drop policy if exists "love_messages_delete_admin"      on public.love_messages;
drop policy if exists "love_messages_delete_partner"    on public.love_messages;

create policy "love_messages_select" on public.love_messages for select
  using (
    recipient_id = auth.uid()
    or exists (
      select 1
      from public.couple_members me
      join public.couple_members partner on partner.couple_id = me.couple_id
      where me.user_id = auth.uid()
        and me.is_active = true
        and partner.user_id = love_messages.recipient_id
        and partner.is_active = true
    )
  );

create policy "love_messages_insert_partner" on public.love_messages for insert
  with check (
    exists (
      select 1
      from public.couple_members me
      join public.couple_members partner on partner.couple_id = me.couple_id
      where me.user_id = auth.uid()
        and me.role in ('boyfriend', 'admin')
        and me.is_active = true
        and partner.user_id = love_messages.recipient_id
        and partner.is_active = true
    )
  );

create policy "love_messages_update_recipient" on public.love_messages for update
  using (recipient_id = auth.uid())
  with check (recipient_id = auth.uid());

create policy "love_messages_delete_partner" on public.love_messages for delete
  using (
    exists (
      select 1
      from public.couple_members me
      join public.couple_members partner on partner.couple_id = me.couple_id
      where me.user_id = auth.uid()
        and me.role in ('boyfriend', 'admin')
        and me.is_active = true
        and partner.user_id = love_messages.recipient_id
        and partner.is_active = true
    )
  );
