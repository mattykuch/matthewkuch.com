# Launch runbook — getting matthewkuch.com live

The site is built and committed locally. These are the steps that need your
GitHub and ecowebhosting accounts. Work through them in order.

---

## Step 1 — Create the GitHub repo

Go to <https://github.com/new> and create:

| Field | Value |
|---|---|
| Owner | **mattykuch** (your personal account, not the bk-advisors org) |
| Repository name | **matthewkuch.com** |
| Visibility | **Public** — required for GitHub Pages on a free account |
| Initialise with README / .gitignore / licence | **No** — leave all three unticked |

> Do **not** use the existing `mattykuch.github.io` repo. Putting a custom domain
> on a *user* site redirects the whole thing and would break every project page
> under it (`/ugmap/`, `/crimeviz/`, `/ug_bumpchart/`, …). A separate project
> repo leaves those untouched.

## Step 2 — Push

In a terminal, from the site folder:

```powershell
cd "C:\Users\HP\Desktop\Parking Lot\1 Frequently Used\Web Projects\matthewkuch.com"
git remote add origin https://github.com/mattykuch/matthewkuch.com.git
git push -u origin main
```

## Step 3 — Turn on Pages

Repo **Settings → Pages → Build and deployment → Source**: choose
**GitHub Actions**. Not "Deploy from a branch".

Then open the **Actions** tab. The push from Step 2 should already have started
a "Render and deploy" run. Wait for the green tick, then visit the URL the
deploy job prints — it will be `https://mattykuch.github.io/matthewkuch.com/`.

**Check the site works there before touching DNS.**

## Step 4 — DNS at ecowebhosting

In <https://my.ecowebhosting.co.uk> → **Domains → My Domains → matthewkuch.com**.

The DNS record editor is usually inside the hosting control panel (StackCP →
DNS Management), not on the domain page itself. Since matthewkuch.com was
registered without a hosting package, that editor may not be reachable. If you
cannot find it, see "If ecowebhosting will not let you edit DNS" below.

**First delete any existing `A` or `CNAME` record on `@` or `www`.** Eco
provisions a parked page by default, and a leftover record makes the domain
flip between GitHub and their parking page, which also blocks the HTTPS
certificate.

Then add these. Set TTL low (300–600 seconds) for the cutover; you can raise it
later.

| Type | Host | Value |
|---|---|---|
| A | @ | `185.199.108.153` |
| A | @ | `185.199.109.153` |
| A | @ | `185.199.110.153` |
| A | @ | `185.199.111.153` |
| AAAA | @ | `2606:50c0:8000::153` |
| AAAA | @ | `2606:50c0:8001::153` |
| AAAA | @ | `2606:50c0:8002::153` |
| AAAA | @ | `2606:50c0:8003::153` |
| CNAME | www | `mattykuch.github.io.` |

The `www` CNAME points at your **account** domain with no repo name on the end.
GitHub works out which repo to serve from the `CNAME` file in this repo.

The AAAA (IPv6) records are optional. If eco's panel does not support them,
skip them — the site still works.

## Step 5 — Point GitHub at the domain

Repo **Settings → Pages → Custom domain**: enter `matthewkuch.com` and save.
GitHub runs a DNS check, then requests a Let's Encrypt certificate.

Once **Enforce HTTPS** becomes available (can take up to 24 hours, usually much
less), tick it.

Optional but worth doing — **verify the domain** so nobody can claim it if the
repo is ever deleted: <https://github.com/settings/pages> → "Add a domain".
It gives you a TXT record named `_github-pages-challenge-mattykuch` to add
alongside the records above.

### Check it

```bash
dig matthewkuch.com +noall +answer -t A       # expect the four 185.199.x.153
dig www.matthewkuch.com +noall +answer        # expect CNAME -> mattykuch.github.io
curl -sI https://matthewkuch.com | head -1    # expect 200
curl -sI https://www.matthewkuch.com | head -1 # expect a 301 to the apex
```

Then load two or three old project pages —
`https://mattykuch.github.io/ugmap/`, `/crimeviz/` — and confirm they still
work. They should; this is the one thing worth eyeballing.

### If ecowebhosting will not let you edit DNS

Registration stays with eco; you just move the nameservers:

1. Create a free Cloudflare account and add `matthewkuch.com`.
2. Add the records from Step 4 there, with the proxy **off** (grey cloud, "DNS
   only"). GitHub must terminate TLS itself.
3. In eco: **Domains → My Domains → Manage → Nameservers → custom**, and enter
   the two Cloudflare nameservers Cloudflare gives you.

Alternatively, raise a support ticket with eco and ask them to add the records.

---

## Step 6 — Redirect the old blog

**Only after `https://matthewkuch.com` is live and serving all seven posts.**

```powershell
cd "C:\Users\HP\Desktop\Parking Lot\1 Frequently Used\Web Projects\matthewkuch.com"
.\tools\make-redirect-stubs.ps1
```

It checks every target returns 200 first and refuses to write anything
otherwise. It prints the git commands to finish. Then commit and push in the
`bk-advisors.github.io` repo.

Keep `bk-advisors.github.io` alive for at least 12 months — that is what carries
the search ranking across. Closing `bk-advisors.com` is separate and fine.

> Benedict Akansiima's grants post is deliberately **not** redirected. It stays
> on the old site.

> After this, treat the old repo as frozen. Running `quarto render` there would
> overwrite the stubs in `docs/`.

---

## Step 7 — Search engines

1. <https://search.google.com/search-console> → add a **Domain** property for
   `matthewkuch.com`. Domain properties verify by DNS TXT only, so add the TXT
   record it gives you at eco (or Cloudflare) alongside the others.
2. Submit `https://matthewkuch.com/sitemap.xml`.
3. Bing Webmaster Tools → **Import from Google Search Console**. Nothing else to do.
4. Test the structured data:
   - <https://search.google.com/test/rich-results> on `https://matthewkuch.com/about.html` (expect Person)
   - and on any post (expect BlogPosting)
5. Update the highest-value inbound links by hand: your LinkedIn profile and any
   LinkedIn articles, your GitHub profile README, email signature.

---

## Step 8 — First real post

```
/new-post
```

in Claude Code, or `.\new-post.ps1 -Title "…"`. Then `git push`. That is the
whole loop.

---

## Two things to decide later

**The Supply Chain Management gap.** Of your five topics, that one rests on a
single 330-word article. Your CV has the material — the UNICEF polio last-mile
delivery strategy, the CHAI vaccines supply chain workstream, the Uganda
last-mile pilot — but none of it is written up. Two or three real posts would
make that pillar rank. Nothing else on the site needs it.

**Where the linked projects live.** `projects.qmd` and `books.qmd` point at
repos under the **bk-advisors** GitHub org (`bk-advisors.github.io/africa-mmr`,
`/bounce-back`, and so on). They work fine, but your personal site currently
depends on the firm's org. If you want to cut that tie, those repos can be
transferred to `mattykuch` later; the links would then need updating.
