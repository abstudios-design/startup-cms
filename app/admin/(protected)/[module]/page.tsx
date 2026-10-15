import Link from "next/link";
import { notFound } from "next/navigation";

const modules: Record<string, { title: string; description: string }> = {
  pages: { title: "Pages", description: "Create and edit website pages, their SEO metadata and reusable sections." },
  posts: { title: "Blog posts", description: "Create articles, add featured images and manage publication status." },
  media: { title: "Media library", description: "Upload and reuse image assets with descriptive alt text." },
  navigation: { title: "Navigation", description: "Manage header/footer menus and their order." },
  settings: { title: "Website settings & SEO", description: "Set site-wide metadata, social links and brand details." }
};

export default async function AdminModulePage({ params }: { params: Promise<{ module: string }> }) {
  const { module } = await params;
  const item = modules[module];
  if (!item) notFound();

  return (
    <main>
      <div className="admin-topline">
        <div><p className="eyebrow">Workspace / {item.title}</p><h1>{item.title}</h1><p className="muted">{item.description}</p></div>
        {module === "pages" && <Link className="btn" href="/admin/pages/new">New page</Link>}
      </div>
      <section className="panel">
        <p><strong>Module scaffolded</strong></p>
        <p className="muted" style={{ lineHeight: 1.7 }}>This screen is a placeholder, not a connected editor yet. The next step is to connect the module to Supabase with server-side validation and Row Level Security.</p>
      </section>
    </main>
  );
}
