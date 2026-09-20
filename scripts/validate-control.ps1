[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
$failures = [System.Collections.Generic.List[string]]::new()

$requiredPaths = @(
    'README.md', 'AGENTS.md', 'source-baseline.yaml',
    'governance/document-control.yaml', 'governance/19-ase-qsre-interface-contract.md',
    'schemas/pack.schema.json', 'contracts/compatibility.yaml',
    'contracts/pde-to-ase.schema.json', 'contracts/ase-to-qsre.schema.json',
    'contracts/qsre-to-pde.schema.json', 'scripts/validate-contracts.ps1',
    '.github/CODEOWNERS', '.github/pull_request_template.md',
    '.github/workflows/validate-control.yml'
)

foreach ($relativePath in $requiredPaths) {
    if (-not (Test-Path -LiteralPath (Join-Path $repoRoot $relativePath))) {
        $failures.Add("Missing required path: $relativePath")
    }
}

foreach ($forbiddenPath in @('workspaces', '.agents', '.cursor', '.codex')) {
    if (Test-Path -LiteralPath (Join-Path $repoRoot $forbiddenPath)) {
        $failures.Add("Environment-specific path is forbidden in engineering-control: $forbiddenPath")
    }
}

$baselinePath = Join-Path $repoRoot 'source-baseline.yaml'
if (Test-Path -LiteralPath $baselinePath) {
    $baseline = Get-Content -Raw -LiteralPath $baselinePath
    foreach ($pattern in @(
        '(?m)^status:\s*staging\s*$',
        '(?m)^authoritative:\s*false\s*$',
        '(?m)^\s*tag:\s*pde-baseline-v0\.1\.0\s*$',
        '(?m)^\s*commit:\s*[0-9a-fA-F]{40}\s*$'
    )) {
        if ($baseline -notmatch $pattern) {
            $failures.Add("source-baseline.yaml does not match required staging provenance pattern: $pattern")
        }
    }
}

$catalogPath = Join-Path $repoRoot 'governance/document-control.yaml'
if (Test-Path -LiteralPath $catalogPath) {
    $catalog = Get-Content -Raw -LiteralPath $catalogPath
    $documentIds = @([regex]::Matches($catalog, '(?m)^\s*-\s+id:\s*(\S+)\s*$') | ForEach-Object { $_.Groups[1].Value })
    $documentPaths = @([regex]::Matches($catalog, '(?m)^\s+path:\s*(.+?)\s*$') | ForEach-Object { $_.Groups[1].Value.Trim() })
    if ($documentIds.Count -ne 20 -or $documentPaths.Count -ne 20) {
        $failures.Add("document-control.yaml must contain 20 document IDs and paths; found IDs=$($documentIds.Count), paths=$($documentPaths.Count)")
    }
    foreach ($duplicate in @($documentIds | Group-Object | Where-Object Count -gt 1)) {
        $failures.Add("Duplicate document ID: $($duplicate.Name)")
    }
    foreach ($relativePath in $documentPaths) {
        $documentPath = Join-Path $repoRoot $relativePath
        if (-not (Test-Path -LiteralPath $documentPath)) {
            $failures.Add("Document-control path does not exist: $relativePath")
            continue
        }
        $document = Get-Content -Raw -LiteralPath $documentPath
        foreach ($label in @('Document ID:', 'Owner:', 'Approver:', 'Scope:', 'Effective date:', 'Review cycle:', 'Changelog:')) {
            if ($document -notmatch "(?m)^$([regex]::Escape($label))") {
                $failures.Add("Missing metadata '$label' in $relativePath")
            }
        }
    }
}

foreach ($jsonFile in @(Get-ChildItem -LiteralPath $repoRoot -Filter '*.json' -File -Recurse -Force)) {
    try {
        Get-Content -Raw -LiteralPath $jsonFile.FullName | ConvertFrom-Json -Depth 100 | Out-Null
    } catch {
        $failures.Add("Invalid JSON: $([IO.Path]::GetRelativePath($repoRoot, $jsonFile.FullName)): $($_.Exception.Message)")
    }
}

$markdownFiles = @(Get-ChildItem -LiteralPath $repoRoot -Filter '*.md' -File -Recurse -Force)
foreach ($markdownFile in $markdownFiles) {
    $text = Get-Content -Raw -LiteralPath $markdownFile.FullName
    foreach ($match in [regex]::Matches($text, '\[[^\]]+\]\(([^)]+)\)')) {
        $target = $match.Groups[1].Value.Trim().Trim('<', '>')
        if ($target -match '^(https?://|mailto:|demo:|#)') { continue }
        $pathPart = ($target -split '#', 2)[0]
        if (-not $pathPart) { continue }
        $absoluteTarget = Join-Path $markdownFile.DirectoryName ([Uri]::UnescapeDataString($pathPart))
        if (-not (Test-Path -LiteralPath $absoluteTarget)) {
            $relativeSource = [IO.Path]::GetRelativePath($repoRoot, $markdownFile.FullName)
            $failures.Add("Broken local link in ${relativeSource}: $target")
        }
    }
}

& (Join-Path $PSScriptRoot 'validate-contracts.ps1')
if ($LASTEXITCODE -ne 0) {
    $failures.Add('Contract validation failed')
}

if ($failures.Count -gt 0) {
    Write-Error ($failures -join [Environment]::NewLine)
    exit 1
}

Write-Host "Control repository is valid. Governance documents: 20. Markdown files: $($markdownFiles.Count)."
exit 0
