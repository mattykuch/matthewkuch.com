<#
.SYNOPSIS
  Scaffold a new blog post folder for matthewkuch.com.
.EXAMPLE
  .\new-post.ps1 -Title "Why domestic revenue decides everything"
  .\new-post.ps1 -Title "The Matthew Effect" -Date 2025-11-05 -Category "Political Economy"
#>
param(
  [Parameter(Mandatory = $true)][string]$Title,
  [string]$Date = (Get-Date -Format 'yyyy-MM-dd'),
  [string]$Category = 'Health Financing',
  [string]$Slug
)

$ErrorActionPreference = 'Stop'
Set-Location -Path $PSScriptRoot

if (-not $Slug) {
  $Slug = $Title.ToLower() -replace "[^a-z0-9]+", "-"
  $Slug = $Slug.Trim('-')
}

$dir = Join-Path 'posts' $Slug
if (Test-Path $dir) { throw "posts\$Slug already exists. Pick a different -Slug." }

New-Item -ItemType Directory -Path (Join-Path $dir 'images') -Force | Out-Null

$front = @"
---
title: "$Title"
date: "$Date"
categories: [$Category]
image: "images/cover.jpg"
image-alt: "Describe the cover image in a few words."
description: "One-sentence hook shown on the blog card and in search results."
draft: true
---

Paste the article below this line, then delete the ``draft: true`` line when it
is ready to publish.
"@

# UTF-8 WITHOUT a BOM. Set-Content -Encoding utf8 writes a BOM on PowerShell 5.1,
# and a BOM before the opening --- breaks Quarto's YAML front-matter parse.
$utf8NoBom = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText(
  (Join-Path $PSScriptRoot (Join-Path $dir 'index.qmd')), $front, $utf8NoBom)

Write-Host ""
Write-Host "Created $dir" -ForegroundColor Green
Write-Host "  1. Put the cover image in $dir\images\cover.jpg"
Write-Host "  2. Write the post in     $dir\index.qmd"
Write-Host "  3. Delete the 'draft: true' line when ready"
Write-Host "  4. git add $dir; git commit -m 'Add post: $Title'; git push"
Write-Host ""
Write-Host "Valid categories: Health Financing, Global Health, Political Economy," -ForegroundColor DarkGray
Write-Host "Data Visualization, Supply Chain Management, Tax & Domestic Resource" -ForegroundColor DarkGray
Write-Host "Mobilisation, Vaccines & Immunisation, Maternal & Child Health" -ForegroundColor DarkGray
