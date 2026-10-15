-- Run this migration in the Supabase SQL Editor or through Supabase CLI.
-- This starter uses a single-admin model initially.

create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text,
  role text not null default 'admin' check (role in ('admin')),
  created_at timestamptz not null default now()
);

create table if not exists public.pages (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  slug text not null unique,
  excerpt text not null default '',
  content jsonb not null default '{}'::jsonb,
  status text not null default 'draft' check (status in ('draft', 'published', 'archived')),
  seo_title text,
  seo_description text,
  canonical_url text,
  og_image_path text,
  published_at timestamptz,
  created_by uuid references auth.users(id) on delete set null,
  updated_by uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists pages_status_idx on public.pages(status);
create index if not exists pages_updated_at_idx on public.pages(updated_at desc);

create table if not exists public.page_sections (
  id uuid primary key default gen_random_uuid(),
  page_id uuid not null references public.pages(id) on delete cascade,
  section_type text not null check (
    section_type in ('hero', 'rich_text', 'features', 'projects', 'testimonials', 'faq', 'cta')
  ),
  content jsonb not null default '{}'::jsonb,
  sort_order integer not null default 0,
  is_visible boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists page_sections_page_order_idx
  on public.page_sections(page_id, sort_order);

create table if not exists public.posts (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  slug text not null unique,
  excerpt text not null default '',
  content jsonb not null default '{}'::jsonb,
  status text not null default 'draft' check (status in ('draft', 'published', 'archived')),
  featured_image_path text,
  seo_title text,
  seo_description text,
  published_at timestamptz,
  created_by uuid references auth.users(id) on delete set null,
  updated_by uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists posts_status_published_idx on public.posts(status, published_at desc);

create table if not exists public.categories (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  slug text not null unique,
  created_at timestamptz not null default now()
);

create table if not exists public.post_categories (
  post_id uuid not null references public.posts(id) on delete cascade,
  category_id uuid not null references public.categories(id) on delete cascade,
  primary key (post_id, category_id)
);

create table if not exists public.media (
  id uuid primary key default gen_random_uuid(),
  storage_path text not null unique,
  file_name text not null,
  alt_text text not null default '',
  mime_type text not null,
  file_size bigint not null check (file_size >= 0),
  width integer,
  height integer,
  uploaded_by uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now()
);

create table if not exists public.navigation_menus (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  location text not null check (location in ('header', 'footer')),
  created_at timestamptz not null default now()
);

create table if not exists public.navigation_items (
  id uuid primary key default gen_random_uuid(),
  menu_id uuid not null references public.navigation_menus(id) on delete cascade,
  parent_id uuid references public.navigation_items(id) on delete cascade,
  label text not null,
  href text not null,
  sort_order integer not null default 0,
  is_visible boolean not null default true,
  created_at timestamptz not null default now()
);

create index if not exists navigation_items_menu_order_idx
  on public.navigation_items(menu_id, sort_order);

create table if not exists public.site_settings (
  key text primary key,
  value jsonb not null default '{}'::jsonb,
  updated_by uuid references auth.users(id) on delete set null,
  updated_at timestamptz not null default now()
);

-- Enable RLS on all tables exposed through Supabase's API.
alter table public.profiles enable row level security;
alter table public.pages enable row level security;
alter table public.page_sections enable row level security;
alter table public.posts enable row level security;
alter table public.categories enable row level security;
alter table public.post_categories enable row level security;
alter table public.media enable row level security;
alter table public.navigation_menus enable row level security;
alter table public.navigation_items enable row level security;
alter table public.site_settings enable row level security;

-- Admins are explicitly provisioned in profiles. A user cannot self-assign a role.
create or replace function public.is_admin()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.profiles p
    where p.id = (select auth.uid()) and p.role = 'admin'
  );
$$;

revoke all on function public.is_admin() from public;
grant execute on function public.is_admin() to anon, authenticated;

-- Profiles: users can read their own profile; only an existing admin can manage profiles.
create policy "Users can read own profile" on public.profiles
  for select to authenticated using (id = (select auth.uid()) or (select public.is_admin()));
create policy "Admins manage profiles" on public.profiles
  for all to authenticated using ((select public.is_admin())) with check ((select public.is_admin()));

-- Published content is public read-only. Admins can manage all records.
create policy "Public reads published pages" on public.pages
  for select to anon, authenticated using (status = 'published' or (select public.is_admin()));
create policy "Admins manage pages" on public.pages
  for all to authenticated using ((select public.is_admin())) with check ((select public.is_admin()));

create policy "Public reads visible sections of published pages" on public.page_sections
  for select to anon, authenticated using (
    is_visible and exists (
      select 1 from public.pages p where p.id = page_id and p.status = 'published'
    )
    or (select public.is_admin())
  );
create policy "Admins manage page sections" on public.page_sections
  for all to authenticated using ((select public.is_admin())) with check ((select public.is_admin()));

create policy "Public reads published posts" on public.posts
  for select to anon, authenticated using (status = 'published' or (select public.is_admin()));
create policy "Admins manage posts" on public.posts
  for all to authenticated using ((select public.is_admin())) with check ((select public.is_admin()));

create policy "Public reads categories" on public.categories
  for select to anon, authenticated using (true);
create policy "Admins manage categories" on public.categories
  for all to authenticated using ((select public.is_admin())) with check ((select public.is_admin()));

create policy "Public reads post categories" on public.post_categories
  for select to anon, authenticated using (
    exists (select 1 from public.posts p where p.id = post_id and p.status = 'published')
    or (select public.is_admin())
  );
create policy "Admins manage post categories" on public.post_categories
  for all to authenticated using ((select public.is_admin())) with check ((select public.is_admin()));

create policy "Admins manage media metadata" on public.media
  for all to authenticated using ((select public.is_admin())) with check ((select public.is_admin()));

create policy "Public reads menus" on public.navigation_menus
  for select to anon, authenticated using (true);
create policy "Admins manage menus" on public.navigation_menus
  for all to authenticated using ((select public.is_admin())) with check ((select public.is_admin()));

create policy "Public reads visible navigation items" on public.navigation_items
  for select to anon, authenticated using (is_visible or (select public.is_admin()));
create policy "Admins manage navigation items" on public.navigation_items
  for all to authenticated using ((select public.is_admin())) with check ((select public.is_admin()));

create policy "Public reads public site settings" on public.site_settings
  for select to anon, authenticated using (key in ('brand', 'social_links', 'seo_defaults'));
create policy "Admins manage site settings" on public.site_settings
  for all to authenticated using ((select public.is_admin())) with check ((select public.is_admin()));

-- Create a private bucket for original uploads; public website assets can later use a dedicated public bucket.
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('cms-media', 'cms-media', false, 5242880, array['image/jpeg','image/png','image/webp','image/avif'])
on conflict (id) do nothing;

create policy "Admins read CMS media" on storage.objects
  for select to authenticated using (bucket_id = 'cms-media' and (select public.is_admin()));
create policy "Admins upload CMS media" on storage.objects
  for insert to authenticated with check (bucket_id = 'cms-media' and (select public.is_admin()));
create policy "Admins update CMS media" on storage.objects
  for update to authenticated using (bucket_id = 'cms-media' and (select public.is_admin()))
  with check (bucket_id = 'cms-media' and (select public.is_admin()));
create policy "Admins delete CMS media" on storage.objects
  for delete to authenticated using (bucket_id = 'cms-media' and (select public.is_admin()));

-- Seed navigation menus and a small set of safe public defaults.
insert into public.navigation_menus (name, location)
values ('Main navigation', 'header'), ('Footer navigation', 'footer')
on conflict (name) do nothing;

insert into public.site_settings (key, value)
values
  ('brand', '{"name":"Your Name","tagline":"Product and UI/UX Designer"}'::jsonb),
  ('seo_defaults', '{"title":"Your Name — Portfolio","description":"Portfolio and case studies"}'::jsonb),
  ('social_links', '{"linkedin":"","behance":"","dribbble":""}'::jsonb)
on conflict (key) do nothing;
