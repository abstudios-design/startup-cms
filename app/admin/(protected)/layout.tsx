import Link from "next/link";
import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { signOutAction } from "./actions";

export default async function AdminLayout({ children }: Readonly<{ children: React.ReactNode }>) {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();

  // The login page is outside this layout. Every route under /admin is protected.
  if (!user) redirect("/admin/login");

  return (
    <div className="admin-wrap">
      <aside className="admin-sidebar">
        <Link className="brand" href="/admin">YOUR NAME® / CMS</Link>
        <nav className="admin-nav" aria-label="Admin navigation">
          <Link className="active" href="/admin">Overview</Link>
          <Link href="/admin/pages">Pages</Link>
          <Link href="/admin/posts">Blog posts</Link>
          <Link href="/admin/media">Media library</Link>
          <Link href="/admin/navigation">Navigation</Link>
          <Link href="/admin/settings">Settings & SEO</Link>
        </nav>
        <form action={signOutAction} style={{ marginTop: 32, padding: "0 12px" }}>
          <button type="submit" className="btn btn-light" style={{ width: "100%" }}>Sign out</button>
        </form>
      </aside>
      <div className="admin-main">{children}</div>
    </div>
  );
}
