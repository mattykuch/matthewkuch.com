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

## Step 4 — DNS via Cloudflare

> **Why not ecowebhosting.** The domain was registered there without a hosting
> package, so eco never created a DNS zone for it. Their nameservers
> (`ns1–ns4.hpdns.net`) answer `REFUSED` for matthewkuch.com, which is why their
> DNS Management page shows "NS Lookup Failed". The registry side is healthy —
> status is only `client transfer prohibited`, the normal 60-day lock. The fix
> is to keep the registration at eco and move the nameservers to Cloudflare,
> which also gets you AAAA, TXT and low-TTL support that eco's panel may lack.

> **Also do this, separately:** click the link in eco's "Verification Required"
> email (deadline 13/09/2026). That is an ICANN registrant check. It is not what
> is blocking DNS today, but missing it suspends the domain.

### 4a. Add the domain to Cloudflare

1. Create a free account at <https://dash.cloudflare.com/sign-up>.
2. **Add a domain** → `matthewkuch.com` → choose the **Free** plan.
3. Cloudflare scans for existing records and will find **none**. That is expected
   — there is no zone to import. Continue.

### 4b. Add the records

In Cloudflare → **DNS → Records → Add record**. Add these nine.

| Type | Name | Content | Proxy |
|---|---|---|---|
| A | `@` | `185.199.108.153` | **DNS only** |
| A | `@` | `185.199.109.153` | **DNS only** |
| A | `@` | `185.199.110.153` | **DNS only** |
| A | `@` | `185.199.111.153` | **DNS only** |
| AAAA | `@` | `2606:50c0:8000::153` | **DNS only** |
| AAAA | `@` | `2606:50c0:8001::153` | **DNS only** |
| AAAA | `@` | `2606:50c0:8002::153` | **DNS only** |
| AAAA | `@` | `2606:50c0:8003::153` | **DNS only** |
| CNAME | `www` | `mattykuch.github.io` | **DNS only** |

> **The proxy toggle must be grey ("DNS only"), not orange.** This is the one
> mistake that breaks everything: an orange-clouded record makes Cloudflare
> terminate TLS itself, which stops GitHub from issuing its certificate and can
> cause redirect loops. Click the orange cloud on each record to turn it grey.

Leave TTL on **Auto**. Delete anything else Cloudflare pre-populated on `@` or
`www`.

### 4c. Point the nameservers at Cloudflare

Cloudflare shows you two nameservers, like `alice.ns.cloudflare.com` and
`bob.ns.cloudflare.com`. Then in eco:

**Domains → My Domains → matthewkuch.com → Nameservers**

1. Select **Use custom nameservers**.
2. Nameserver 1 and 2 = the two Cloudflare names. **Clear fields 3, 4 and 5** —
   leaving `ns3.hpdns.net` / `ns4.hpdns.net` in place will break resolution.
3. **Change Nameservers**.

Back in Cloudflare, click **Check nameservers**. It emails you when the zone goes
**Active** — usually minutes, occasionally a few hours.

### 4d. Confirm it resolves

```powershell
Resolve-DnsName matthewkuch.com -Type A -Server 8.8.8.8
Resolve-DnsName www.matthewkuch.com -Server 8.8.8.8
```

Expect the four `185.199.x.153` addresses on the apex, and `www` resolving via
`mattykuch.github.io`. Do not move on until this works.

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
