Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$SkillDir = Join-Path $HOME ".claude\skills"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host "=== agent-spec skills installer ==="
Write-Host

# Step 1: Install CLI
$agentSpec = Get-Command agent-spec -ErrorAction SilentlyContinue
if ($agentSpec) {
    $current = try {
        (& agent-spec --version) 2>$null
    } catch {
        "unknown"
    }
    Write-Host "[ok] agent-spec CLI already installed: $current"
} else {
    Write-Host "[..] Installing agent-spec CLI via cargo..."
    $cargo = Get-Command cargo -ErrorAction SilentlyContinue
    if ($cargo) {
        & cargo install agent-spec
        Write-Host "[ok] agent-spec CLI installed"
    } else {
        Write-Host "[!!] cargo not found. Install Rust first: https://rustup.rs"
        Write-Host "     Then run: cargo install agent-spec"
        exit 1
    }
}

Write-Host

# Step 2: Install skills
New-Item -ItemType Directory -Force -Path $SkillDir | Out-Null

$skills = @(
    "agent-spec-tool-first",
    "agent-spec-authoring",
    "agent-spec-estimate"
)

foreach ($skill in $skills) {
    $src = Join-Path $ScriptDir "skills\$skill"
    $dst = Join-Path $SkillDir $skill

    if (-not (Test-Path -LiteralPath $src -PathType Container)) {
        Write-Host "[skip] $skill - not found in $ScriptDir\skills\"
        continue
    }

    if (Test-Path -LiteralPath $dst) {
        Remove-Item -LiteralPath $dst -Recurse -Force
    }

    Copy-Item -LiteralPath $src -Destination $dst -Recurse
    Write-Host "[ok] $skill -> $dst"
}

Write-Host
Write-Host "Done. All agent-spec skills are ready for Claude Code."
Write-Host "Verify with: Get-ChildItem $HOME\.claude\skills\agent-spec-*"
