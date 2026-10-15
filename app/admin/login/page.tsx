import type { Metadata } from "next";
import Link from "next/link";
import LoginForm from "./login-form";

export const metadata: Metadata = { title: "Admin login" };

export default function AdminLoginPage() {
  return (
    <main className="shell" style={{ paddingTop: 28 }}>
      <header className="site-nav">
        <Link className="brand" href="/">YOUR NAME® / CMS</Link>
        <Link className="eyebrow" href="/">← View website</Link>
      </header>
      <section style={{ maxWidth: 440, margin: "72px auto" }}>
        <p className="eyebrow">Private workspace</p>
        <h1 style={{ fontSize: 40, letterSpacing: "-.06em", margin: "12px 0" }}>Welcome back.</h1>
        <p className="muted" style={{ lineHeight: 1.6, marginBottom: 28 }}>Sign in with the admin account created in Supabase. Public sign-up is intentionally disabled.</p>
        <div className="panel"><LoginForm /></div>
      </section>
    </main>
  );
}
