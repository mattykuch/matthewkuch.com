# matthewkuch.com

Personal website of Matthew Kuch — management consultant in global health and
writer. Built with [Quarto](https://quarto.org), rendered by GitHub Actions and
served from GitHub Pages at <https://matthewkuch.com>.

## Publishing

There is no local build step. Push to `main` and the workflow renders and
deploys; the site is live in about two minutes.

```
git add posts/<slug>/
git commit -m "Add post: <Title>"
git push
```

To add a post, use `/new-post` in Claude Code, or run `.\new-post.ps1 -Title "…"`.
The full guide is in [How-to-Add-a-Blog-Post.md](How-to-Add-a-Blog-Post.md).

## Layout

| Path | What it is |
|---|---|
| `index.qmd` | Home page (bio + three most recent posts) |
| `about.qmd` | Bio, with `Person` structured data |
| `blog.qmd` | Auto-generated listing of `posts/*` + RSS |
| `projects.qmd` | Interactive data stories, hosted elsewhere |
| `books.qmd` | Long-form book projects |
| `cv.qmd` | CV, with the PDF in `assets/` |
| `posts/<slug>/` | One post per folder: `index.qmd` + `images/` |
| `posts/_metadata.yml` | Shared post defaults (author, format, freeze) |
| `theme/brand.scss` | Colours, fonts, components |
| `jsonld.lua` | Emits `BlogPosting` structured data per post |
| `_freeze/` | Cached R results **and** vendored widget JS — committed on purpose |
| `.github/workflows/publish.yml` | Render and deploy |

## Local preview

```
quarto preview
```

Requires Quarto 1.8.27+. R is not needed for prose posts.
