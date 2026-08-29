---
name: new-post
description: Add a new blog post to the matthewkuch.com Quarto site from text the user pastes (often a LinkedIn article). Scaffolds posts/<slug>/, cleans and writes the body, places cover + in-body images, previews, and publishes by pushing to GitHub. Use whenever the user wants to add / create / publish a blog post, "put this article on the site", or pastes article text for the blog.
---

# Add a new post to matthewkuch.com

This site is a Quarto website that **renders in GitHub Actions**, not locally.
Publishing is `git push` — CI runs `quarto render` and deploys to GitHub Pages.
Never commit `_site/`. The blog page auto-lists every `posts/*/index.qmd`, so
there is no post list to hand-edit.

## 1. Gather inputs (ask only for what is missing)

- **Title**
- **Body text** (the user pastes it; often LinkedIn prose)
- **Publish date** — `YYYY-MM-DD`. If only a month is given, propose a date and say so.
- **Category(ies)** — from this controlled list ONLY:
  `Health Financing` · `Global Health` · `Political Economy` ·
  `Data Visualization` · `Supply Chain Management` ·
  `Tax & Domestic Resource Mobilisation` · `Vaccines & Immunisation` ·
  `Maternal & Child Health`
- **Cover image** + any in-body images. From a `.docx`, extract with:
  `quarto pandoc <file>.docx -f docx -t gfm --extract-media=_import -o _import/x.md`
- **Author** — defaults to "Matthew Kuch" via `posts/_metadata.yml`; only set
  `author:` to override.

## 2. Scaffold (run from the REPO ROOT, not from inside posts/)

Slug = kebab-case of the title.

```
mkdir -p posts/<slug>/images
cp posts/_post-template.qmd posts/<slug>/index.qmd
```

## 3. Write `posts/<slug>/index.qmd`

```yaml
---
title: "…"
date: "YYYY-MM-DD"
categories: [Category One, Category Two]
image: "images/cover.<ext>"
image-alt: "Short factual description of the cover image."
description: "One-sentence hook for the card and for search results."
---
```

- The template ships `draft: true`. **Delete that line** for a finished post;
  keep it if the post is not ready.
- `description` and `image-alt` are not optional — they are the meta
  description and the social-card alt text, and both matter for SEO.
- Body cleanup when pasting prose (especially from Word or LinkedIn):
  - blank line between paragraphs; `## Heading` for sections; `- ` / `1. ` lists
  - strip `<span …>` / `<u>…</u>` wrappers left by docx conversion
  - links → `[text](url)`
  - **escape every literal dollar sign as `\$`** (KaTeX is on; a bare `$` starts maths)
  - images → `![caption](images/<file>)`, with the file in `posts/<slug>/images/`
- Keep the article's own headings at `##` or lower. The `title:` is the page's
  only `h1`.

## 4. Preview locally (optional but recommended)

```
quarto preview
```

Pure-prose posts need no R. Stop with Ctrl+C. Do not commit `_site/`.

## 5. Publish

```
git add posts/<slug>/
git commit -m "Add post: <Title>"
git push
```

GitHub Actions renders and deploys; live at https://matthewkuch.com in about
two minutes. Check the run in the repo's Actions tab if it does not appear.

## Gotchas / facts

- **CI has no R.** Posts that execute code must ship frozen results in
  `_freeze/`, and the workflow fails the build if they do not. Only
  `posts/health-financing/` runs R (it is pinned `freeze: true`). If you edit
  that post's code or data, render locally with R on PATH
  (`$env:PATH = "C:\Program Files\R\R-4.4.1\bin;" + $env:PATH`) and commit the
  regenerated `_freeze/`.
- `_freeze/site_libs/` holds vendored htmlwidget JS (highcharts, jquery, …).
  Do not delete it; without it the health-financing chart renders blank.
- `output-dir` is `_site` and `_site/` is gitignored. The deployed site is the
  Actions artifact, never a committed folder.
- A post that is only a teaser to an external interactive belongs on
  **`projects.qmd`**, not in `posts/`. Thin posts hurt SEO.
- Teaser-style cover images live in `assets/projects/`.
