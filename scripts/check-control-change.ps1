[CmdletBinding()]
param(
    [string]$BaseRef,
    [string]$PullRequestBody = $env:PR_BODY,
    [string[]]$ChangedPaths
)

$ErrorActionPreference = 'Stop'

if (-not $BaseRef -and -not $ChangedPaths) {
    & (Join-Path $PSScriptRoot 'validate-control.ps1')
    exit $LASTEXITCODE
}

$changed = if ($ChangedPaths) { @($ChangedPaths) } else { @(git diff --name-only "$BaseRef...HEAD") }
if (-not $ChangedPaths -and $LASTEXITCODE -ne 0) {
    Write-Error "Unable to read git diff against $BaseRef"
    exit 1
}

$controlledPatterns = @(
    'governance/*', 'contracts/*', 'schemas/*', 'templates/*', 'shared-skills/*',
    'scripts/*', '.github/*', 'docs/*', 'AGENTS.md', 'source-baseline.yaml'
)
$controlled = @($changed | Where-Object {
    $path = $_.Replace('\', '/')
    @($controlledPatterns | Where-Object { $path -like $_ }).Count -gt 0
})

if ($controlled.Count -eq 0) {
    Write-Host 'No controlled files changed.'
    exit 0
}

function Get-PrField {
    param([string]$Body, [string]$Name)
    if ([string]::IsNullOrWhiteSpace($Body)) { return $null }
    $match = [regex]::Match($Body, "(?im)^\s*$([regex]::Escape($Name))\s*:\s*(?<value>.*?)\s*$")
    if (-not $match.Success) { return $null }
    return ([regex]::Replace($match.Groups['value'].Value, '<!--.*?-->', '')).Trim()
}

function Test-MeaningfulField {
    param([AllowNull()][string]$Value)
    if ([string]::IsNullOrWhiteSpace($Value) -or $Value.Length -lt 20) { return $false }
    return $Value -notmatch '(?i)^\s*(n/?a|none|no impact|нет|не применимо|без влияния|tbd|todo|-)(\b|\s|$)'
}

$reason = Get-PrField -Body $PullRequestBody -Name 'Reason'
$governanceImpact = Get-PrField -Body $PullRequestBody -Name 'Governance impact'
if (-not (Test-MeaningfulField $reason) -or -not (Test-MeaningfulField $governanceImpact)) {
    Write-Error "Controlled PR must contain meaningful 'Reason:' and 'Governance impact:' values of at least 20 characters."
    exit 1
}

Write-Host 'Change rationale is present.'
& (Join-Path $PSScriptRoot 'validate-control.ps1')
exit $LASTEXITCODE
