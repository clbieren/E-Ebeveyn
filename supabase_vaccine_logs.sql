-- Supabase SQL Editor'da çalıştırın. RLS politikalarını kendi güvenlik modelinize göre ekleyin.

create table if not exists public.child_vaccine_logs (
  id uuid primary key default gen_random_uuid(),
  child_id uuid not null references public.children (id) on delete cascade,
  family_id uuid not null,
  user_id uuid not null,
  vaccine_id text not null,
  is_completed boolean not null default true,
  completed_at timestamptz not null default now(),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (child_id, vaccine_id)
);

create index if not exists child_vaccine_logs_child_id_idx on public.child_vaccine_logs (child_id);
