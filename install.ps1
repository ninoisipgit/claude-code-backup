# Installs the personal Claude Code skills/agents into ~/.claude on this machine.
# Run from anywhere:  powershell -ExecutionPolicy Bypass -File .\install.ps1

$src  = Join-Path $PSScriptRoot 'claude'
$dest = Join-Path $env:USERPROFILE '.claude'

New-Item -ItemType Directory -Force -Path (Join-Path $dest 'skills') | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $dest 'agents') | Out-Null

Copy-Item (Join-Path $src 'skills\*') (Join-Path $dest 'skills') -Recurse -Force
Copy-Item (Join-Path $src 'agents\*') (Join-Path $dest 'agents') -Recurse -Force

Write-Host "Installed to $dest. Restart Claude Code, then type '/' to confirm migrate-feature and fdp-table-and-constants are listed."
