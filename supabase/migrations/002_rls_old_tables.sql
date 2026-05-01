-- Enable RLS on legacy tables and add user-scoped policies.
-- Run once in Supabase SQL Editor.

-- ─── wishes ───────────────────────────────────────────────────────────────────
alter table public.wishes enable row level security;

create policy "wishes_select_own"  on public.wishes for select using (user_id = auth.uid());
create policy "wishes_insert_own"  on public.wishes for insert with check (user_id = auth.uid());
create policy "wishes_update_own"  on public.wishes for update using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "wishes_delete_own"  on public.wishes for delete using (user_id = auth.uid());

-- ─── scores ───────────────────────────────────────────────────────────────────
alter table public.scores enable row level security;

create policy "scores_select_own"  on public.scores for select using (user_id = auth.uid());
create policy "scores_insert_own"  on public.scores for insert with check (user_id = auth.uid());
create policy "scores_delete_own"  on public.scores for delete using (user_id = auth.uid());

-- ─── achievements ─────────────────────────────────────────────────────────────
alter table public.achievements enable row level security;

create policy "achievements_select_own"  on public.achievements for select using (user_id = auth.uid());
create policy "achievements_insert_own"  on public.achievements for insert with check (user_id = auth.uid());

-- ─── love_messages ────────────────────────────────────────────────────────────
-- Recipient reads their own letters; partner (boyfriend/admin in same couple)
-- can read/insert/delete letters addressed to recipient.

alter table public.love_messages enable row level security;

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

-- ─── used_trivia ──────────────────────────────────────────────────────────────
alter table public.used_trivia enable row level security;

create policy "used_trivia_select_own"  on public.used_trivia for select using (user_id = auth.uid());
create policy "used_trivia_insert_own"  on public.used_trivia for insert with check (user_id = auth.uid());
create policy "used_trivia_delete_own"  on public.used_trivia for delete using (user_id = auth.uid());

-- ─── used_words ───────────────────────────────────────────────────────────────
alter table public.used_words enable row level security;

create policy "used_words_select_own"  on public.used_words for select using (user_id = auth.uid());
create policy "used_words_insert_own"  on public.used_words for insert with check (user_id = auth.uid());
create policy "used_words_delete_own"  on public.used_words for delete using (user_id = auth.uid());

-- ─── used_colors ──────────────────────────────────────────────────────────────
-- Table may not exist yet; create it if missing, then add RLS.
create table if not exists public.used_colors (
  id          uuid primary key default gen_random_uuid(),
  question    text not null,
  user_id     uuid not null references auth.users(id) on delete cascade,
  created_at  timestamptz not null default now()
);

alter table public.used_colors enable row level security;

create policy "used_colors_select_own"  on public.used_colors for select using (user_id = auth.uid());
create policy "used_colors_insert_own"  on public.used_colors for insert with check (user_id = auth.uid());
create policy "used_colors_delete_own"  on public.used_colors for delete using (user_id = auth.uid());

-- ─── used_anagrams ────────────────────────────────────────────────────────────
create table if not exists public.used_anagrams (
  id          uuid primary key default gen_random_uuid(),
  word        text not null,
  user_id     uuid not null references auth.users(id) on delete cascade,
  created_at  timestamptz not null default now()
);

alter table public.used_anagrams enable row level security;

create policy "used_anagrams_select_own"  on public.used_anagrams for select using (user_id = auth.uid());
create policy "used_anagrams_insert_own"  on public.used_anagrams for insert with check (user_id = auth.uid());
create policy "used_anagrams_delete_own"  on public.used_anagrams for delete using (user_id = auth.uid());

-- ─── used_pairs ───────────────────────────────────────────────────────────────
create table if not exists public.used_pairs (
  id          uuid primary key default gen_random_uuid(),
  question    text not null,
  user_id     uuid not null references auth.users(id) on delete cascade,
  created_at  timestamptz not null default now()
);

alter table public.used_pairs enable row level security;

create policy "used_pairs_select_own"  on public.used_pairs for select using (user_id = auth.uid());
create policy "used_pairs_insert_own"  on public.used_pairs for insert with check (user_id = auth.uid());
create policy "used_pairs_delete_own"  on public.used_pairs for delete using (user_id = auth.uid());
