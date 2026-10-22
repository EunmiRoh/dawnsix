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

-- 자동 백업 : 하루 한 번 그날 처음 동기화할 때의 클라우드 기록 (최근 30일만 보관)
create table if not exists public.dawnsix_backups (
  user_id    uuid not null references auth.users(id) on delete cascade,
  day        date not null,
  data       jsonb not null,
  days_count int  not null default 0,
  created_at timestamptz not null default now(),
  primary key (user_id, day)
);

alter table public.dawnsix_backups enable row level security;

drop policy if exists "own backups select" on public.dawnsix_backups;
create policy "own backups select" on public.dawnsix_backups for select using ((select auth.uid()) = user_id);
drop policy if exists "own backups insert" on public.dawnsix_backups;
create policy "own backups insert" on public.dawnsix_backups for insert with check ((select auth.uid()) = user_id);
drop policy if exists "own backups update" on public.dawnsix_backups;
create policy "own backups update" on public.dawnsix_backups for update using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);
drop policy if exists "own backups delete" on public.dawnsix_backups;
create policy "own backups delete" on public.dawnsix_backups for delete using ((select auth.uid()) = user_id);

-- 30일 지난 백업은 새 백업이 들어올 때 지운다
create or replace function public.dawnsix_backups_prune() returns trigger
language plpgsql security invoker set search_path = '' as $$
begin
  delete from public.dawnsix_backups where user_id = new.user_id and day < new.day - 30;
  return new;
end $$;

drop trigger if exists dawnsix_backups_prune on public.dawnsix_backups;
create trigger dawnsix_backups_prune after insert or update on public.dawnsix_backups
  for each row execute function public.dawnsix_backups_prune();
