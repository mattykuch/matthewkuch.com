# CLAUDE.md

Guidance for Claude Code when working in this repository.

## What this is

`matthewkuch.com` is a single Quarto website — the personal site of Matthew
Kuch, management consultant in global health and writer. It consolidates writing
that previously lived on `bk-advisors.com`, `bk-advisors.github.io` and
`mattykuch.github.io`.

**Deployment is CI, not a committed build.** `.github/workflows/publish.yml`
renders the site on every push to `main` and deploys `_site/` as a GitHub Pages
artifact. Repo Settings → Pages → Source must be **GitHub Actions**.
`_site/` is gitignored and must never be committed — this differs from the old
`bk-advisors.github.io` repo, which commits `docs/`. Do not carry that habit over.

## Architecture

- **Listings are auto-generated.** `blog.qmd` lists every `posts/*/index.qmd`;
  `index.qmd` shows the three most recent. **Never hand-edit a post list.**
- **One post = one folder:** `posts/<slug>/index.qmd` with images in
  `posts/<slug>/images/`. Clean URL: `/posts/<slug>/`.
- **Shared post defaults** live in `posts/_metadata.yml` (author, html format,
  freeze). Post front matter needs `title`, `date`, `categories`, `image`,
  `image-alt`, `description`.
- **Template:** `posts/_post-template.qmd`. The `_` prefix means Quarto ignores it.
- **Theme:** `theme/brand.scss` — deep slate/teal with an amber accent, Source
  Sans 3 for UI and Source Serif 4 for article prose. Deliberately not the BK
  Advisors blue/red.
- **`render:` allowlist** in `_quarto.yml` covers the six top-level pages plus
  `posts/*/index.qmd`. `assets/`, `lab/`, `CNAME` and `.nojekyll` are copied
  verbatim via `resources:`.
- **Projects and Books link out.** `projects.qmd` and `books.qmd` point at sites
  hosted in other repos under the `bk-advisors` GitHub org. Nothing is re-hosted here.

## SEO layer — do not quietly remove any of this

- `site-url` in `_quarto.yml` is what generates `sitemap.xml` and `robots.txt`
  and makes social image URLs absolute. Removing it silently kills all three.
- `canonical-url: true` emits the trailing-slash canonical (`/posts/<slug>/`),
  which resolves the duplicate against the sitemap's `index.html` form.
- `jsonld.lua` emits `BlogPosting` structured data for every post, reading the
  front matter. It normalises Quarto's display-formatted date back to ISO 8601 —
  schema.org requires ISO, and Quarto hands filters "November 5, 2025".
- `about.qmd` carries `Person` structured data via front-matter `include-in-header`.
- Every post needs `description` and `image-alt`. They are the meta description
  and the social-card alt text.

## R and `freeze`

Only **`posts/health-financing/`** executes R: it pulls a child doc
`eac-health-exp-line.Rmd` (a `highcharter` chart) reading
`posts/health-financing/data/eac-govt-health-exp.csv`. It is pinned `freeze: true`.

- **CI has no R.** The committed `_freeze/posts/health-financing/` replays the
  chart. The workflow's "Check freeze coverage" step fails the build if a post
  with a code chunk has no frozen results — that is deliberate; do not weaken it.
- **`_freeze/site_libs/` holds vendored htmlwidget JavaScript** (highcharts,
  highchart-binding, htmlwidgets, jquery, proj4js, htmltools-fill). Quarto copies
  it into `_site/site_libs/`. Freeze stores the chart's *HTML* but not these
  library files, so without them the chart renders blank. Do not delete them.
- If you edit that post's code or data, R 4.4.1 is at
  `C:\Program Files\R\R-4.4.1\bin` (not on PATH). Prepend it, render, and commit
  the regenerated `_freeze/`. Packages: `highcharter`, `tidyverse`, `readxl`.
- To re-execute everything in CI, run the workflow manually with the
  `execute_r` input set to true.

## Adding a post

Use the project skill: `/new-post` (`.claude/skills/new-post/SKILL.md`). It
encodes the whole workflow. `How-to-Add-a-Blog-Post.md` is the non-technical
version, and `new-post.ps1` scaffolds a folder without Claude.

Controlled category vocabulary — keep tags to this set:
`Health Financing`, `Global Health`, `Political Economy`, `Data Visualization`,
`Supply Chain Management`, `Tax & Domestic Resource Mobilisation`,
`Vaccines & Immunisation`, `Maternal & Child Health`.

## Gotchas

- **`_site/` is never committed.** `.gitignore` excludes it; `_freeze/` is
  explicitly tracked.
- **`.gitattributes` forces LF.** The workflow contains a bash script; CRLF
  would break it on the Linux runner.
- **One `h1` per page.** Quarto emits it from `title:`, so post bodies start at
  `##`. `index.qmd` has no `title:` precisely because its hero supplies the `h1`.
- **`main.content p` / `main.content img` out-rank component classes.** The
  serif body rule and the rounded-image rule are more specific than
  `.mk-hero__photo img` etc., so the overrides at the bottom of `brand.scss`
  exist on purpose. Check specificity before "tidying" them.
- **External-link icons on `file://`.** Opening `_site/index.html` directly makes
  Quarto's JS treat every link as external and add a ↗ icon. That is an artifact
  of the `file://` origin, not a bug. Verify over HTTP or on the live site.
- **Thin teaser posts belong on `projects.qmd`**, not in `posts/`. Three such
  teasers were deliberately folded into Projects during the migration.
- **A running local server locks `_site/`** and makes `quarto render` fail with
  `os error 32`. Stop it first.
- Render with **Quarto 1.8.27** — the version pinned in CI.
