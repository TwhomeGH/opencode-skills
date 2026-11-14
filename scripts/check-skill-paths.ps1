<#
.SYNOPSIS
    Check that skill definitions do not hardcode machine-specific paths.

.DESCRIPTION
    Scans skills/**/SKILL.md for absolute local paths (drive letters, UNC shares,
    /Users/, /home/, $HOME/). Skill files must resolve their own resources from the
    harness-provided base directory, detect target projects from the session cwd or
    git root, or fall back to an environment variable.

    Exits 0 when clean, 1 when any file contains a hardcoded path.

.PARAMETER Root
    Repository root. Defaults to the parent directory of this script.

.EXAMPLE
    .\scripts\check-skill-paths.ps1
#>
[CmdletBinding()]
param(
    [string]$Root = (Split-Path -Parent $PSScriptRoot)
)

$pattern = '([A-Za-z]:\\|\\\\[A-Za-z]|/Users/|/home/|\$HOME/)'
$skillsDir = Join-Path $Root 'skills'
$files = @(Get-ChildItem $skillsDir -Recurse -Filter 'SKILL.md' -File -ErrorAction SilentlyContinue)
$problems = @()

foreach ($file in $files) {
    Select-String -LiteralPath $file.FullName -Pattern $pattern | ForEach-Object {
        $problems += [pscustomobject]@{
            File = $file.FullName
            Line = $_.LineNumber
            Text = $_.Line.Trim()
        }
    }
}

if ($problems.Count -eq 0) {
    "OK：$($files.Count) 個 SKILL.md 沒有寫死路徑"
    exit 0
}

$problems | Format-Table -AutoSize | Out-String -Width 160 | Write-Output
"FAIL：$($problems.Count) 處寫死路徑"
exit 1
