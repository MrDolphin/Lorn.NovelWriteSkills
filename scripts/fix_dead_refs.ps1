<#
.SYNOPSIS
  批量补全 skill 中死亡 reference 文件的引用
.DESCRIPTION
  读取审计 CSV，对每个标记为 dead 的 reference 文件，
  在其对应 SKILL.md 的 `## 继续读取的 references` 节中补入引用行。
  如果 SKILL.md 缺该节，则在文件末尾补充创建（含使用条件）。
#>

param(
  [string]$CsvPath = "audit_crosref.csv",
  [string]$RepoRoot = (Get-Location).Path,
  [switch]$WhatIf
)

Set-StrictMode -Version Latest

# 读取审计结果
$report = Import-Csv $CsvPath

# 筛选 dead 文件
$deadFiles = $report | Where-Object Status -eq 'dead'
$deadByDir = $deadFiles | Group-Object SkillDir

Write-Host "=== 补引用计划 ===" -ForegroundColor Cyan
Write-Host "共 $($deadFiles.Count) 个死亡文件，分布在 $($deadByDir.Count) 个 skill 目录" -ForegroundColor Yellow

$fixedCount = 0
$newSectionCount = 0

foreach ($group in $deadByDir) {
  $relDir = $group.Name
  $skillDir = [System.IO.Path]::Combine($RepoRoot, $relDir)
  $smPath = Join-Path $skillDir "SKILL.md"

  if (-not (Test-Path $smPath)) {
    Write-Warning "SKILL.md not found: $smPath"
    continue
  }

  # 读取 SKILL.md
  $content = Get-Content $smPath -Raw
  $origContent = $content
  $lines = $content -split "`r`n"

  # 构造要追加的引用行（每个 ref 文件一行）
  $refLinesToAdd = @()
  foreach ($item in $group.Group) {
    $refFile = $item.RefFile
    $refDesc = $item.RefDesc
    $line = "- `references/$refFile` — $refDesc"
    # 不重复添加（检查是否已有该行）
    if ($content -notmatch [regex]::Escape($refFile)) {
      $refLinesToAdd += $line
    }
  }

  if ($refLinesToAdd.Count -eq 0) {
    # 所有文件已被引用，跳过
    continue
  }

  # 检查是否已有 ## 继续读取的 references 节
  $hasSection = $content -match '##\s*继续读取的 references'

  if ($hasSection) {
    # ── 已存在 references 节 → 追加到节末尾 ──
    $sectionPattern = '(##\s*继续读取的 references.*?)(?=\r?\n## |\r?\n<!-- =====|\z)'
    $newContent = $content -replace $sectionPattern, {
      $match = $_.Value
      # 在节末尾插入新引用行
      $match + "`r`n" + ($refLinesToAdd -join "`r`n")
    }
    $content = $newContent
  } else {
    # ── 不存在 references 节 → 创建新节 ──
    # 放在文件末尾（Layer 3 区域内）
    $newSection = @(
      "`r`n## 继续读取的 references",
      "`r`n> 以下 references 为当前 skill 目录下的补充文件，按需加载。",
      ""
    ) + ($refLinesToAdd | ForEach-Object { "`r`n$_" }) + @("`r`n")

    $content = $content.TrimEnd("`r`n ") + ($newSection -join "")
    $newSectionCount++
  }

  if ($content -ne $origContent) {
    if (-not $WhatIf) {
      [System.IO.File]::WriteAllText($smPath, $content, [System.Text.UTF8Encoding]::new($false))
    }
    Write-Host "  $(if ($WhatIf) {'[WOULD]'} else {'[FIX]'}) $relDir ($($refLinesToAdd.Count) refs)" -ForegroundColor Green
    $fixedCount++
  }
}

Write-Host "`n=== 完成 ===" -ForegroundColor Cyan
Write-Host "已处理: $fixedCount 个 skill 目录"
Write-Host "新增 references 节: $newSectionCount 个"
Write-Host "补入引用行: $($deadFiles.Count) 个" -NoNewline
if ($WhatIf) { Write-Host " (预览模式)" } else { Write-Host "" }
