-- ลอยกระทงออนไลน์: shared river for the public (GitHub Pages) build.
-- Paste this whole file into Supabase → SQL Editor → New query, then press Run.
-- Running it again is safe.

-- Every floated krathong. `hidden` lets the owner take one down from the Table Editor.
create table if not exists public.krathongs (
  id         uuid primary key default gen_random_uuid(),
  type       text not null check (type in ('leaf','lotus','marigold','orchid','ice','coconut',
                                           'term','amber','mono','prompt','lock','shield','audit')),
  name       text not null check (char_length(name) between 1 and 24),
  wish       text not null check (char_length(wish) between 1 and 120),
  hidden     boolean not null default false,
  created_at timestamptz not null default now()
);
create index if not exists krathongs_created_idx on public.krathongs (created_at desc);

-- One "ขอให้คำอธิษฐานเป็นจริง" per browser per krathong.
create table if not exists public.amens (
  krathong_id uuid not null references public.krathongs(id) on delete cascade,
  client_id   text not null check (char_length(client_id) between 8 and 64),
  created_at  timestamptz not null default now(),
  primary key (krathong_id, client_id)
);

-- Visitors cannot backdate a krathong or float one already hidden.
create or replace function public.krathong_defaults() returns trigger
language plpgsql as $$
begin
  new.created_at := now();
  new.hidden := false;
  return new;
end $$;
drop trigger if exists krathong_defaults on public.krathongs;
create trigger krathong_defaults before insert on public.krathongs
  for each row execute function public.krathong_defaults();

-- Row-level security: visitors (the anon key) may read and add, never edit or delete.
alter table public.krathongs enable row level security;
alter table public.amens     enable row level security;

drop policy if exists "read visible krathongs" on public.krathongs;
create policy "read visible krathongs" on public.krathongs for select to anon using (hidden = false);
drop policy if exists "float a krathong" on public.krathongs;
create policy "float a krathong" on public.krathongs for insert to anon with check (true);

drop policy if exists "read amens" on public.amens;
create policy "read amens" on public.amens for select to anon using (true);
drop policy if exists "send an amen" on public.amens;
create policy "send an amen" on public.amens for insert to anon with check (true);

grant select, insert on public.krathongs to anon;
grant select, insert on public.amens     to anon;

-- What the page reads: visible krathongs with their amen counts.
create or replace view public.krathong_feed with (security_invoker = true) as
  select k.id, k.type, k.name, k.wish, k.created_at,
         (select count(*) from public.amens a where a.krathong_id = k.id)::int as amen_count
  from public.krathongs k
  where k.hidden = false;
grant select on public.krathong_feed to anon;
