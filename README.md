# matthewkuch.com

Personal website of Matthew Kuch — management consultant in global health and
writer. Writing on health financing, global health, political economy, data
visualisation and supply chains.

Built with [Quarto](https://quarto.org), rendered by GitHub Actions and served
from GitHub Pages at <https://matthewkuch.com>.

## Publishing

No local build step. Push to `main`; the workflow renders the site and deploys
it, live in about two minutes.

```
git add posts/<slug>/
git commit -m "Add post: <Title>"
git push
```

One post is one folder: `posts/<slug>/index.qmd` with its images in
`posts/<slug>/images/`. The blog listing, category cloud, search index and RSS
feed all regenerate themselves — there is no post list to edit.

## Layout

| Path | What it is |
|---|---|
| `index.qmd` | Home page — bio and the three most recent posts |
| `about.qmd` | Bio, with `Person` structured data |
| `blog.qmd` | Auto-generated listing of `posts/*`, plus the RSS feed |
| `projects.qmd` | Interactive data stories, hosted separately |
| `books.qmd` | Long-form book projects |
| `cv.qmd` | CV, with the PDF in `assets/` |
| `posts/_metadata.yml` | Shared post defaults — author, format, freeze |
| `posts/_post-template.qmd` | Scaffold for a new post |
| `theme/brand.scss` | Colours, fonts, components |
| `jsonld.lua` | Emits `BlogPosting` structured data for each post |
| `_freeze/` | Cached R results and vendored widget JS — committed on purpose |
| `.github/workflows/publish.yml` | Render and deploy |

## Local preview

```
quarto preview
```

Needs Quarto 1.8.27 or later. R is not required — the one post that executes R
replays from the committed `_freeze/` cache.
