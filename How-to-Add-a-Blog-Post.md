# How to add a blog post to matthewkuch.com

## The easy way: let Claude do it

1. Open this folder in **Claude Code** (VS Code or the desktop app).
2. Type **`/new-post`**, or just say *"add a new blog post"*.
3. **Paste the article text.** Give the title, the publish date, and a cover
   image (drag the file into the project, or say where it is).
4. Claude creates the post folder, cleans up the formatting, places the images,
   picks the category, previews it, and pushes. It confirms when it is live.

Everything below is the manual fallback.

---

## The manual way

### Step 0 — Be in the project root

Open a terminal in the `matthewkuch.com` folder itself. The prompt must end
`...\matthewkuch.com>`, **not** `...\posts>`. If unsure, paste:

```
Set-Location "C:\Users\HP\Desktop\Parking Lot\1 Frequently Used\Web Projects\matthewkuch.com"
```

### Step 1 — Create the post folder

Pick a short slug in lowercase with hyphens, e.g. `the-matthew-effect`.

```
mkdir posts\the-matthew-effect\images
copy posts\_post-template.qmd posts\the-matthew-effect\index.qmd
```

If you ever see a `posts\posts\` folder, you ran this from inside `posts` —
delete the stray folder and redo from Step 0.

### Step 2 — Paste the article and fill in the top block

Open `posts\the-matthew-effect\index.qmd`, fill the front matter (keep the
quotes), delete the instructional comment, and paste the article below it:

```
---
title: "The Matthew Effect"
date: "2025-11-05"
categories: [Political Economy]
image: "images/cover.png"
image-alt: "Short description of the cover image."
description: "One sentence shown on the blog card and in Google results."
---
```

Drop the cover image and any in-article images into the post's `images\` folder.

**Make it visible:** new posts start hidden with a `draft: true` line. When the
post is finished, **delete that whole line**.

### Step 3 — Preview (optional)

```
quarto preview
```

Opens it in the browser. Ctrl+C to stop. You do **not** have to render before
publishing — GitHub does that for you.

### Step 4 — Publish

```
git add posts\the-matthew-effect\
git commit -m "Add post: The Matthew Effect"
git push
```

Live at <https://matthewkuch.com> in about two minutes. The home page, blog
listing, categories, search and RSS feed all update themselves.

---

## Reference

### Front-matter fields

| Field | What to put | Example |
|---|---|---|
| `title` | Headline, in quotes | `"The Matthew Effect"` |
| `date` | `YYYY-MM-DD`, in quotes | `"2025-11-05"` |
| `categories` | From the list below, in `[ ]` | `[Political Economy]` |
| `image` | Cover; the file must be in `images\` | `"images/cover.png"` |
| `image-alt` | Plain description of that image | `"Chart of compounding advantage"` |
| `description` | One sentence for the card and for Google | `"Why advantage compounds."` |

**Categories — use only these, spelled exactly:**
Health Financing · Global Health · Political Economy · Data Visualization ·
Supply Chain Management · Tax & Domestic Resource Mobilisation ·
Vaccines & Immunisation · Maternal & Child Health

### LinkedIn to web cheatsheet

| You want | Type this |
|---|---|
| New paragraph | a **blank line** between paragraphs |
| Heading | `## My Heading` |
| Bullet / numbered list | `- point` / `1. point` |
| Quote | `> the quoted text` |
| Link | `[words people see](https://the-url)` |
| Image | `![caption](images/the-file.jpg)` (file in `images\`) |
| A real dollar sign | `\$50` (a plain `$` turns on maths) |

### If something looks wrong

- **Image missing** — the file must be in *this post's* `images\` folder and the
  name must match exactly, capitals and extension included.
- **Post not showing** — either the front matter is missing a closing `---` or a
  quote, or the `draft: true` line is still there.
- **The build failed** — open the repo's **Actions** tab on GitHub; the red run
  says which file and line. Most often it is an unescaped `$`.
- **An error mentioning R or knitr** — only the "Cost of Staying Alive" post uses
  R. New prose posts never need it. If you edited that post, ask Claude to
  re-render it and commit `_freeze/`.
- **Still stuck** — open Claude Code and paste the error.

### Where things live

| | |
|---|---|
| Posts | `posts\<slug>\index.qmd` |
| Post images | `posts\<slug>\images\` |
| Interactive projects list | `projects.qmd` |
| Books list | `books.qmd` |
| Bio | `about.qmd` |
| CV | `cv.qmd` (and `assets\matthew-kuch-cv.pdf`) |
| Colours and fonts | `theme\brand.scss` |
| Site settings, nav | `_quarto.yml` |
| Build/deploy | `.github\workflows\publish.yml` |
