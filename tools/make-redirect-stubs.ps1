<#
.SYNOPSIS
  Generate cross-domain redirect stubs on the OLD blog (bk-advisors.github.io)
  pointing at the new matthewkuch.com URLs.

.DESCRIPTION
  GitHub Pages cannot serve real 301s. Google treats an instant meta refresh as
  a permanent redirect, so meta refresh + rel=canonical is the supported way to
  move link equity across domains.

  RUN THIS ONLY AFTER matthewkuch.com IS LIVE and every target URL returns 200.
  The script checks each target first and refuses to write a stub for any target
  that is not reachable.

  It writes into BOTH the source tree and docs/ (the old site is served from
  main:/docs), then tells you what to commit. It does not commit or push.

.EXAMPLE
  .\tools\make-redirect-stubs.ps1
  .\tools\make-redirect-stubs.ps1 -OldRepo "C:\path\to\bk-advisors.github.io" -WhatIf
#>
param(
  [string]$OldRepo = "C:\Users\HP\Desktop\Parking Lot\1 Frequently Used\Web Projects\bk-github\bk-advisors.github.io",
  [switch]$WhatIf
)

$ErrorActionPreference = 'Stop'
$NewSite = 'https://matthewkuch.com'

if (-not (Test-Path $OldRepo)) { throw "Old repo not found: $OldRepo" }

# old path (relative to the old site root)  ->  new absolute URL
$map = [ordered]@{
  # migrated essays, same slug
  'posts/health-financing/index.html'                  = "$NewSite/posts/health-financing/"
  'posts/displacement-effect/index.html'               = "$NewSite/posts/displacement-effect/"
  'posts/honest-people-corrupt-politicians/index.html' = "$NewSite/posts/honest-people-corrupt-politicians/"
  'posts/the-matthew-effect/index.html'                = "$NewSite/posts/the-matthew-effect/"
  'posts/public-health-cost-of-elections/index.html'   = "$NewSite/posts/public-health-cost-of-elections/"
  'posts/tax-revenue-health-financing/index.html'      = "$NewSite/posts/tax-revenue-health-financing/"
  'posts/ug-exports/index.html'                        = "$NewSite/posts/ug-exports/"

  # thin teasers folded into the Projects page
  'posts/hpv-awareness-day/index.html'                 = "$NewSite/projects.html"
  'posts/measles-vaccines-work/index.html'             = "$NewSite/projects.html"
  'posts/maternal-health-sdg3/index.html'              = "$NewSite/projects.html"

  # legacy flat URLs — repoint straight at the new site, never chain two hops
  'blog/posts/health-financing.html'                   = "$NewSite/posts/health-financing/"
  'blog/posts/displacement-effect.html'                = "$NewSite/posts/displacement-effect/"
  'blog/posts/ug-exports.html'                         = "$NewSite/posts/ug-exports/"
  # this article was never finished and exists nowhere; send it to the blog index
  'blog/posts/why-african-govts-struggle.html'         = "$NewSite/blog.html"

  # site root and feed
  'index.html'                                         = "$NewSite/"
  'index.xml'                                          = "$NewSite/blog.xml"
}

# NOT redirected on purpose:
#   posts/grants/  -- written by Benedict Akansiima, not migrated. Leave it live.
#   blog/posts/grants.html -- ditto.

function New-Stub([string]$Target) {
@"
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<title>Moved to matthewkuch.com</title>
<link rel="canonical" href="$Target">
<meta http-equiv="refresh" content="0; url=$Target">
<meta name="referrer" content="no-referrer-when-downgrade">
<script>location.replace("$Target");</script>
</head>
<body>
<p>This page has moved to <a href="$Target">$Target</a>.</p>
</body>
</html>
"@
}

Write-Host "Checking that every target is live before writing anything..." -ForegroundColor Cyan
$dead = @()
foreach ($t in ($map.Values | Select-Object -Unique)) {
  try {
    $r = Invoke-WebRequest -Uri $t -Method Head -MaximumRedirection 5 -TimeoutSec 20 -UseBasicParsing
    if ($r.StatusCode -ne 200) { $dead += "$t -> $($r.StatusCode)" }
    else { Write-Host "  200  $t" -ForegroundColor DarkGray }
  } catch {
    $dead += "$t -> unreachable"
  }
}
if ($dead.Count -gt 0) {
  Write-Host ""
  Write-Host "ABORTING. These targets are not live yet:" -ForegroundColor Red
  $dead | ForEach-Object { Write-Host "  $_" -ForegroundColor Red }
  Write-Host "Publish matthewkuch.com first, then re-run." -ForegroundColor Red
  exit 1
}

Write-Host ""
$written = 0
foreach ($old in $map.Keys) {
  $target = $map[$old]
  $html   = New-Stub $target
  # The old site is served from /docs, so that is what must carry the stubs.
  # Only blog/posts/*.html also exists at the repo root, as a source resource
  # copied into docs/ on render -- update both of those. Everywhere else the
  # root holds .qmd sources, and writing .html beside them would just create
  # inert duplicates that confuse anyone reading the repo later.
  $bases = if ($old -like 'blog/posts/*') {
             @($OldRepo, (Join-Path $OldRepo 'docs'))
           } else {
             @((Join-Path $OldRepo 'docs'))
           }
  foreach ($base in $bases) {
    $path = Join-Path $base $old
    $dir  = Split-Path $path -Parent
    if ($WhatIf) { Write-Host "would write $path -> $target"; continue }
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    $utf8NoBom = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($path, $html, $utf8NoBom)
    $written++
  }
  if (-not $WhatIf) { Write-Host "  $old  ->  $target" -ForegroundColor Green }
}

if ($WhatIf) { Write-Host "`n(dry run, nothing written)"; exit 0 }

Write-Host ""
Write-Host "Wrote $written files." -ForegroundColor Green
Write-Host ""
Write-Host "IMPORTANT: the old site renders with Quarto, and a render would" -ForegroundColor Yellow
Write-Host "overwrite docs/posts/*. Do NOT run 'quarto render' there again."   -ForegroundColor Yellow
Write-Host "Remove those posts from the render list first, or treat the repo"  -ForegroundColor Yellow
Write-Host "as frozen from here on."                                            -ForegroundColor Yellow
Write-Host ""
Write-Host "Next:" -ForegroundColor Cyan
Write-Host "  cd `"$OldRepo`""
Write-Host "  git add -A"
Write-Host "  git commit -m `"Redirect migrated posts to matthewkuch.com`""
Write-Host "  git push origin main"
