-- 새벽 여섯 시 : 기록 테이블
create table if not exists public.dawnsix_logs (
  user_id    uuid primary key references auth.users(id) on delete cascade,
  data       jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

alter table public.dawnsix_logs enable row level security;

-- 본인 기록만 읽고 쓸 수 있게
drop policy if exists "own rows select" on public.dawnsix_logs;
create policy "own rows select" on public.dawnsix_logs
  for select using (auth.uid() = user_id);

drop policy if exists "own rows insert" on public.dawnsix_logs;
create policy "own rows insert" on public.dawnsix_logs
  for insert with check (auth.uid() = user_id);

drop policy if exists "own rows update" on public.dawnsix_logs;
create policy "own rows update" on public.dawnsix_logs
  for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
