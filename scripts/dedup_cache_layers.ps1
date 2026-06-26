<#
.SYNOPSIS
  修复因 annotate_cache_layers.ps1 脚本 bug 导致的重复缓存层标注。
  对每个文件中重复的 Layer 1/2/3 注释，仅保留最后一个（位置正确的原始标注）。

.DESCRIPTION
  在 annotate_cache_layers.ps1 的跳过检测正则 `<!--\s*=\s*Layer\s+\d` 
  未能匹配 `<!-- ===== Layer` 模式（5 个等号）时，已标注文件被二次写入
  导致重复。此脚本修复：对每个文件中的同一 Layer 编号，删除除最后一次
  出现外的所有实例。
#>

param(
  [string]$Path = (Get-Location).Path,
  [switch]$WhatIf
)

$fixed = 0
$skipped = 0
$files = Get-ChildItem $Path -Recurse -Filter "SKILL.md" -File |
  Where-Object { $_.FullName -notmatch '\\node_modules\\' -and $_.FullName -notmatch '\\.git\\' }

foreach ($f in $files) {
  $c = Get-Content $f.FullName -Raw
  if (-not $c) { continue }
  $orig = $c

  # 去重 Layer 1
  $lastL1 = 0; $idx = 0
  while (($idx = $c.IndexOf('<!-- ===== Layer 1:', $idx)) -ge 0) { $lastL1 = $idx; $idx++ }
  if ($lastL1 -gt 0) {  # 至少出现一次
    $firstL1 = $c.IndexOf('<!-- ===== Layer 1:')
    if ($firstL1 -ne $lastL1) {  # 不止一次
      # 删除第一次出现的 Layer 1 及其 close tag
      $closeIdx = $c.IndexOf('-->', $firstL1) + 3
      $before = $c.Substring(0, $firstL1)
      $after = $c.Substring($closeIdx)
      $c = $before + $after
      $c = $c.TrimStart("`r`n ")
    }
  }

  # 去重 Layer 3
  $lastL3 = 0; $idx = 0
  while (($idx = $c.IndexOf('<!-- ===== Layer 3:', $idx)) -ge 0) { $lastL3 = $idx; $idx++ }
  if ($lastL3 -gt 0) {
    $firstL3 = $c.IndexOf('<!-- ===== Layer 3:')
    if ($firstL3 -ne $lastL3) {
      $closeIdx = $c.IndexOf('-->', $firstL3) + 3
      $c = $c.Substring(0, $firstL3) + $c.Substring($closeIdx)
    }
  }

  # 去重 Layer 2
  $lastL2 = 0; $idx = 0
  while (($idx = $c.IndexOf('<!-- ===== Layer 2:', $idx)) -ge 0) { $lastL2 = $idx; $idx++ }
  if ($lastL2 -gt 0) {
    $firstL2 = $c.IndexOf('<!-- ===== Layer 2:')
    if ($firstL2 -ne $lastL2) {
      $closeIdx = $c.IndexOf('-->', $firstL2) + 3
      $c = $c.Substring(0, $firstL2) + $c.Substring($closeIdx)
    }
  }

  if ($c -ne $orig) {
    if (-not $WhatIf) {
      [System.IO.File]::WriteAllText($f.FullName, $c, [System.Text.UTF8Encoding]::new($false))
    }
    $fixed++
    $rel = [System.IO.Path]::GetRelativePath($Path, $f.FullName)
    Write-Host "  FIX $rel" -ForegroundColor Green
  } else {
    $skipped++
  }
}

Write-Host "`n完成: $fixed 个文件修复, $skipped 个无需操作" -ForegroundColor Cyan
