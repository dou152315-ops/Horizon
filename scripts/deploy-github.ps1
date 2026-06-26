$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
Set-Location $repoRoot

Write-Host "Checking GitHub login..."
gh auth status | Out-Host

$user = gh api user --jq ".login"
$repo = "$user/Horizon"

Write-Host "GitHub user: $user"
Write-Host "Target repo: $repo"

$repoExists = $true
try {
    gh repo view $repo | Out-Null
} catch {
    $repoExists = $false
}

if (-not $repoExists) {
    Write-Host "Forking Thysrael/Horizon to your GitHub account..."
    gh repo fork Thysrael/Horizon --clone=false
}

Write-Host "Setting git remotes..."
git remote set-url origin "https://github.com/$repo.git"

$hasUpstream = $true
try {
    git remote get-url upstream | Out-Null
} catch {
    $hasUpstream = $false
}

if (-not $hasUpstream) {
    git remote add upstream "https://github.com/Thysrael/Horizon.git"
}

Write-Host "Preparing local commit..."
git add data/config.github.json DEPLOY_zh.md scripts/deploy-github.ps1

git diff --cached --quiet
if ($LASTEXITCODE -ne 0) {
    git commit -m "Configure Horizon GitHub deployment"
} else {
    Write-Host "No local deployment changes to commit."
}

Write-Host "Pushing to GitHub..."
git push -u origin main

$deepseekKey = Read-Host "Paste DEEPSEEK_API_KEY, or press Enter to skip"
if ($deepseekKey.Trim().Length -gt 0) {
    gh secret set DEEPSEEK_API_KEY --repo $repo --body $deepseekKey
    Write-Host "Saved DEEPSEEK_API_KEY to GitHub Secrets."
} else {
    Write-Host "Skipped DEEPSEEK_API_KEY. Add it later in GitHub Settings -> Secrets and variables -> Actions."
}

Write-Host "Enabling workflow..."
gh workflow enable daily-summary.yml --repo $repo

Write-Host "Starting first workflow run..."
gh workflow run daily-summary.yml --repo $repo --ref main

Write-Host ""
Write-Host "Done. Open this page after a few minutes:"
Write-Host "https://github.com/$repo/actions"
Write-Host ""
Write-Host "Then enable GitHub Pages:"
Write-Host "Settings -> Pages -> Deploy from a branch -> gh-pages -> /"
