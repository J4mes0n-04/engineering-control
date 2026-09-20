[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
$contractsRoot = Join-Path $repoRoot 'contracts'
$failures = [System.Collections.Generic.List[string]]::new()
$loadedExamples = @{}

$contracts = @(
    @{ Name = 'pde-to-ase'; Schema = 'pde-to-ase.schema.json'; Example = 'examples/pde-to-ase.example.json'; Type = 'pde-to-ase'; Version = '1.0.0' },
    @{ Name = 'ase-to-qsre'; Schema = 'ase-to-qsre.schema.json'; Example = 'examples/ase-to-qsre.example.json'; Type = 'ase-to-qsre'; Version = '1.0.0' },
    @{ Name = 'qsre-to-pde'; Schema = 'qsre-to-pde.schema.json'; Example = 'examples/qsre-to-pde.example.json'; Type = 'qsre-to-pde'; Version = '1.0.0' }
)

foreach ($contract in $contracts) {
    $schemaPath = Join-Path $contractsRoot $contract.Schema
    $examplePath = Join-Path $contractsRoot $contract.Example

    if (-not (Test-Path -LiteralPath $schemaPath)) {
        $failures.Add("Missing schema: $($contract.Schema)")
        continue
    }
    if (-not (Test-Path -LiteralPath $examplePath)) {
        $failures.Add("Missing example: $($contract.Example)")
        continue
    }

    try {
        $schema = Get-Content -Raw -LiteralPath $schemaPath | ConvertFrom-Json -Depth 100
        $exampleText = Get-Content -Raw -LiteralPath $examplePath
        $example = $exampleText | ConvertFrom-Json -Depth 100
        if (-not ($exampleText | Test-Json -SchemaFile $schemaPath -ErrorAction Stop)) {
            $failures.Add("Schema validation failed: $($contract.Example)")
        }
        if ($schema.additionalProperties -ne $false) {
            $failures.Add("Root additionalProperties must be false: $($contract.Schema)")
        }
        if ($example.contract_type -ne $contract.Type) {
            $failures.Add("Unexpected contract_type in $($contract.Example)")
        }
        if ($example.contract_version -ne $contract.Version) {
            $failures.Add("Unexpected contract_version in $($contract.Example)")
        }
        $loadedExamples[$contract.Name] = $example

        $invalidExample = $exampleText | ConvertFrom-Json -Depth 100
        $invalidExample | Add-Member -NotePropertyName 'unexpected_field' -NotePropertyValue 'must-be-rejected'
        $invalidText = $invalidExample | ConvertTo-Json -Depth 100
        if ($invalidText | Test-Json -SchemaFile $schemaPath -ErrorAction SilentlyContinue) {
            $failures.Add("Schema accepts an unknown root property: $($contract.Schema)")
        }
    } catch {
        $failures.Add("Invalid schema or example for $($contract.Name): $($_.Exception.Message)")
    }
}

if ($loadedExamples.Count -eq $contracts.Count) {
    $pde = $loadedExamples['pde-to-ase']
    $ase = $loadedExamples['ase-to-qsre']
    $qsre = $loadedExamples['qsre-to-pde']

    if (@($pde.outcome_id, $ase.outcome_id, $qsre.outcome_id) | Select-Object -Unique | Measure-Object | Select-Object -ExpandProperty Count | Where-Object { $_ -ne 1 }) {
        $failures.Add('Contract chain uses different outcome_id values')
    }
    if ($ase.pde_handoff_id -ne $pde.handoff_id) {
        $failures.Add('ASE to QSRE contract does not reference the PDE handoff_id')
    }
    foreach ($candidate in @($ase.pack, $qsre.pack)) {
        if ($candidate.commit_sha -ne $pde.pack.commit_sha -or $candidate.version -ne $pde.pack.version) {
            $failures.Add('Contract chain uses different Pack version or commit SHA')
        }
    }
    if ($qsre.implementation.commit_sha -ne $ase.implementation.commit_sha) {
        $failures.Add('QSRE feedback does not reference the ASE implementation commit SHA')
    }

    $requirementIds = @($pde.requirements.acceptance_criteria.id) + @($pde.requirements.nfrs.id)
    $duplicateRequirementIds = @($requirementIds | Group-Object | Where-Object Count -gt 1)
    if ($duplicateRequirementIds.Count -gt 0) {
        $failures.Add("Duplicate PDE requirement ids: $($duplicateRequirementIds.Name -join ', ')")
    }
    $referencedIds = @($pde.delivery_slices.requirement_ids) + @($pde.expected_evidence.requirement_ids)
    foreach ($id in $referencedIds) {
        if ($id -notin $requirementIds) {
            $failures.Add("PDE handoff references an unknown requirement: $id")
        }
    }
    foreach ($id in $requirementIds) {
        if ($id -notin @($ase.coverage.requirement_id)) {
            $failures.Add("ASE to QSRE coverage is missing requirement: $id")
        }
    }
}

$compatibilityPath = Join-Path $contractsRoot 'compatibility.yaml'
if (-not (Test-Path -LiteralPath $compatibilityPath)) {
    $failures.Add('Missing contracts/compatibility.yaml')
} else {
    $compatibility = Get-Content -Raw -LiteralPath $compatibilityPath
    foreach ($requiredText in @('control_repository_status: staging', 'pde_to_ase:', 'ase_to_qsre:', 'qsre_to_pde:', 'version: 1.0.0', 'status: not-deployed')) {
        if ($compatibility -notmatch [regex]::Escape($requiredText)) {
            $failures.Add("Compatibility matrix is missing '$requiredText'")
        }
    }
}

if ($failures.Count -gt 0) {
    Write-Error ($failures -join [Environment]::NewLine)
    exit 1
}

Write-Host "Validated $($contracts.Count) contract schema(s), examples and compatibility matrix."
exit 0
