-- Shibori product intake — run once in Supabase → SQL Editor → New query → Run
-- Project: pemslcyrbyapcicaekfp

-- 1) Products table -------------------------------------------------------
create table if not exists public.products (
  id                  uuid primary key default gen_random_uuid(),
  created_at          timestamptz not null default now(),
  title               text not null,
  category            text,
  status              text default 'Active',
  price               numeric,
  compare_at          numeric,
  sizes               text,
  colors              text,
  fabric              text,
  care                text,
  description         text,
  image_urls          jsonb default '[]'::jsonb,
  video_url           text,
  uploaded_to_shopify boolean default false
);

alter table public.products enable row level security;

-- Internal intake tool: the public form (anon) may add + read submissions.
drop policy if exists "intake insert" on public.products;
drop policy if exists "intake select" on public.products;
create policy "intake insert" on public.products for insert to anon, authenticated with check (true);
create policy "intake select" on public.products for select to anon, authenticated using (true);

-- 2) Public storage bucket for photos + videos ---------------------------
insert into storage.buckets (id, name, public)
values ('product-media', 'product-media', true)
on conflict (id) do nothing;

drop policy if exists "media upload" on storage.objects;
drop policy if exists "media read"   on storage.objects;
create policy "media upload" on storage.objects for insert to anon, authenticated with check (bucket_id = 'product-media');
create policy "media read"   on storage.objects for select to anon, authenticated using (bucket_id = 'product-media');
