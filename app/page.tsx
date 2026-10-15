import Link from "next/link";

const projects = [
  {
    number: "01",
    name: "Product experience",
    type: "Product design · Case study",
    description: "A clear, outcome-focused case study can live here once you add your real project details."
  },
  {
    number: "02",
    name: "Design system",
    type: "UI systems · Components",
    description: "Show how you turn reusable components, tokens and patterns into consistent product experiences."
  }
];

export default function HomePage() {
  return (
    <main className="shell">
      <header className="site-nav">
        <Link className="brand" href="/">YOUR NAME<span aria-hidden="true">®</span></Link>
        <nav className="nav-links" aria-label="Main navigation">
          <a href="#work">Work</a>
          <a href="#about">About</a>
          <a href="mailto:hello@example.com">Contact ↗</a>
        </nav>
      </header>

      <section className="hero" id="about">
        <span className="pill"><span className="dot" /> Available for select projects</span>
        <p className="eyebrow" style={{ marginTop: 28 }}>Portfolio · Product & UI/UX Design</p>
        <h1>Designing useful digital experiences with clarity and purpose.</h1>
        <p>I turn complex problems into simple, thoughtful interfaces. Explore selected work across product design, UX strategy and design systems.</p>
      </section>

      <section className="section" id="work">
        <div className="section-heading">
          <div><p className="eyebrow">Selected work</p><h2>Projects & case studies</h2></div>
          <span className="eyebrow">2024 — 2026</span>
        </div>
        <div className="project-grid">
          {projects.map((project) => (
            <article className="project-card" key={project.number}>
              <div><span className="eyebrow">{project.number} / {project.type}</span><h3>{project.name}</h3><p>{project.description}</p></div>
              <p style={{ marginTop: 28, fontSize: 13 }}>Case study coming soon ↗</p>
            </article>
          ))}
        </div>
      </section>

      <footer className="site-footer">
        <span>© {new Date().getFullYear()} YOUR NAME. Designed with intention.</span>
        <Link href="/admin/login">CMS admin ↗</Link>
      </footer>
    </main>
  );
}
