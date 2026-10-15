import type { Metadata } from "next";

export const metadata: Metadata = { title: "CMS overview" };

export default function AdminDashboard() {
  return (
    <main>
      <div className="admin-topline">
        <div><p className="eyebrow">Workspace / Overview</p><h1>Good to see you.</h1><p className="muted">Your website content, all in one place.</p></div>
      </div>
      <div className="stat-grid">
        <div className="stat"><span className="eyebrow">Pages</span><strong>—</strong><p className="muted">Connect content in Phase 2</p></div>
        <div className="stat"><span className="eyebrow">Blog posts</span><strong>—</strong><p className="muted">Connect content in Phase 3</p></div>
        <div className="stat"><span className="eyebrow">Media assets</span><strong>—</strong><p className="muted">Connect storage in Phase 5</p></div>
      </div>
      <section className="panel">
        <p className="eyebrow">Next step</p>
        <h2 style={{ marginTop: 8 }}>Your admin foundation is ready.</h2>
        <p className="muted" style={{ lineHeight: 1.7 }}>After connecting Supabase, the next implementation milestone is the Pages module: database schema, secure list view, create/edit form, draft/publish status and public rendering.</p>
      </section>
    </main>
  );
}
