# astrolabe publish helper (PowerShell 5.1 compatible, ASCII only)
#
# Usage:
#   .\scripts\publish.ps1              # update -> dry-run -> publish
#   .\scripts\publish.ps1 -DryOnly     # update -> dry-run only
#   .\scripts\publish.ps1 -SkipUpdate  # skip the leading `moon update`
#
# Why this exists (measured on this machine, 2026-11-27):
#   1. `moon publish` may return exit code 0 even when the upload did NOT happen.
#      Judge success by the output text: "Server status: 200 OK" (real publish),
#      "Server status: 202 Accepted" (--dry-run). Any line starting with "Error:" = failure.
#   2. `moon update` must run before publish, otherwise the registry index is stale.
#   3. PowerShell 5.1: `& moon ... 2>&1 | Out-String` prints NativeCommandError noise and
#      $ErrorActionPreference='SilentlyContinue' silently drops stderr text. Redirecting
#      through cmd.exe into a temp file and reading it back as UTF-8 keeps both the full
#      output and the real exit code.

param(
  [switch]$DryOnly,
  [switch]$SkipUpdate
)

$ErrorActionPreference = 'Continue'
$root = Split-Path -Parent $PSScriptRoot
Set-Location $root

$tmp = Join-Path $root '_build_publish_out.txt'
$tmp2 = Join-Path $root '_build_publish_dry.txt'

function Invoke-Moon {
  param([string]$MoonArgs, [string]$OutFile)
  if (Test-Path $OutFile) { Remove-Item $OutFile -Force }
  $line = "moon $MoonArgs > `"$OutFile`" 2>&1"
  cmd /c $line | Out-Null
  $code = $LASTEXITCODE
  $text = if (Test-Path $OutFile) { Get-Content $OutFile -Raw -Encoding UTF8 } else { '' }
  return @{ Code = $code; Text = $text }
}

function Get-ServerStatus {
  param([string]$Text)
  $m = [regex]::Match($Text, 'Server status:\s*(\d{3})')
  if ($m.Success) { return $m.Groups[1].Value } else { return '' }
}

function Test-HasError {
  param([string]$Text)
  return [regex]::IsMatch($Text, '(?m)^\s*Error:')
}

if (-not $SkipUpdate) {
  Write-Host '[1/3] moon update'
  $u = Invoke-Moon -MoonArgs 'update' -OutFile $tmp
  Write-Host ("        exit={0}" -f $u.Code)
}

Write-Host '[2/3] moon publish --dry-run'
$d = Invoke-Moon -MoonArgs 'publish --dry-run' -OutFile $tmp2
$dStatus = Get-ServerStatus $d.Text
Write-Host ("        exit={0} status={1}" -f $d.Code, $dStatus)
if ((Test-HasError $d.Text) -or ($dStatus -ne '202')) {
  Write-Host 'DRY-RUN FAILED. Output tail:'
  $d.Text -split "`n" | Select-Object -Last 20 | ForEach-Object { Write-Host "  $_" }
  Remove-Item $tmp, $tmp2 -Force -ErrorAction SilentlyContinue
  exit 1
}

if ($DryOnly) {
  Write-Host 'DRY-RUN OK (202 Accepted). Not publishing (-DryOnly).'
  Remove-Item $tmp, $tmp2 -Force -ErrorAction SilentlyContinue
  exit 0
}

Write-Host '[3/3] moon publish'
$p = Invoke-Moon -MoonArgs 'publish' -OutFile $tmp
$pStatus = Get-ServerStatus $p.Text
Write-Host ("        exit={0} status={1}" -f $p.Code, $pStatus)

Remove-Item $tmp, $tmp2 -Force -ErrorAction SilentlyContinue

if ((Test-HasError $p.Text) -or ($pStatus -ne '200')) {
  Write-Host 'PUBLISH FAILED (expected Server status: 200 OK). Re-run with -DryOnly and inspect.'
  exit 1
}

Write-Host 'PUBLISH OK (200). Verify with: moon search "walkzzz/astrolabe"'
exit 0
