# Startup CMS Starter

A small portfolio/personal-brand website and CMS foundation built with Next.js App Router, TypeScript, Supabase Auth/PostgreSQL/Storage, and a form-first admin UX.

## Included in this starter

- Responsive portfolio homepage placeholder
- Admin login form using Supabase Auth
- Protected `/admin` route layout
- Sign-out server action
- Supabase SSR browser/server clients and session-refresh middleware
- Responsive starter styling with plain CSS (no UI framework dependency yet)
- Initial PostgreSQL schema, RLS policies, menus/settings seed data, and private media bucket
- Placeholder admin routes for Pages, Blog, Media, Navigation, and Settings

**Not yet implemented:** CRUD forms, page-section editing, blog editor, image upload UI, SEO editor, preview/publishing actions, and automated tests. These are the next milestones.

## 1. Requirements

- Node.js 20.9 or newer
- npm
- A Supabase project
- Git

## 2. Install and run

```bash
cp .env.example .env.local
npm install
npm run dev
```

Open `http://localhost:3000`.

Fill `.env.local` with your Supabase project URL and publishable/anon key. Never put a Supabase service-role key in a `NEXT_PUBLIC_` variable or browser code.

## 3. Configure Supabase

1. Create a Supabase project.
2. Open **Project Settings → API** and copy the project URL and publishable/anon key into `.env.local`.
3. Open **SQL Editor** and run `supabase/migrations/0001_initial_schema.sql`.
4. In **Authentication → Users**, create/invite your first admin account. Disable public sign-ups in Auth settings.
5. Copy the new user's UUID from Authentication → Users.
6. In the SQL Editor, grant the account its admin profile. Replace the UUID and display name:

```sql
insert into public.profiles (id, display_name, role)
values ('REPLACE-WITH-AUTH-USER-UUID', 'Site Admin', 'admin')
on conflict (id) do update set display_name = excluded.display_name, role = 'admin';
```

The `profiles` table intentionally has no trigger that lets users self-assign admin privileges. Provision admins manually for the first version.

## 4. Environment variables

Required:

- `NEXT_PUBLIC_SUPABASE_URL`
- `NEXT_PUBLIC_SUPABASE_ANON_KEY`
- `NEXT_PUBLIC_SITE_URL`

The site URL is reserved for canonical URLs and sitemap generation in a later phase.

## 5. Routes

- `/` — portfolio homepage placeholder
- `/admin/login` — admin login
- `/admin` — protected dashboard
- `/admin/pages`, `/admin/posts`, `/admin/media`, `/admin/navigation`, `/admin/settings` — protected module placeholders

## 6. Security notes

- `middleware.ts` refreshes the auth session; it is not the sole authorization boundary.
- `app/admin/(protected)/layout.tsx` calls `supabase.auth.getUser()` and redirects unauthenticated users. The login route is outside this protected route group.
- Supabase RLS policies protect database operations even if a client bypasses the UI.
- Public users can read published pages/posts only.
- Admin status is controlled by the `profiles` table. Do not add client-side role editing.
- The media bucket is private. A later media UI should use authenticated uploads and signed URLs or a deliberate public delivery bucket for public-facing images.
- Before production, add rate limiting for login, security headers, error monitoring, tests, and a verified backup/restore process.

## 7. Build verification

```bash
npm run typecheck
npm run lint
npm run build
```

Run these after installing dependencies and setting environment variables.

## 8. Suggested implementation order

1. Connect Supabase and verify admin login.
2. Build Pages CRUD and slug validation.
3. Add draft/publish workflow and public dynamic page rendering.
4. Add typed page sections with ordered form-based editing.
5. Add blog CRUD and categories.
6. Add secure media upload and image selection.
7. Add menu editor and global site settings.
8. Add SEO metadata, sitemap, preview, revalidation, tests and production deployment.
