$ErrorActionPreference = 'Stop'
Write-Host 'Install this skill for Claude Code and Codex using the standard Skills CLI (Node.js 22.20+ required).'
npx skills add https://raw.githubusercontent.com/BoBolol-CN/fluorescence-image-analysis/main/fluorescence-image-analysis.zip -g -a claude-code codex --copy
if ($LASTEXITCODE -ne 0) { throw 'Skills CLI installation failed. See the repository README for ZIP/manual installation.' }
