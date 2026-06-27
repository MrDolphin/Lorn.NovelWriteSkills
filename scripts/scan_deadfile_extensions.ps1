<#
.SYNOPSIS
  死文件审计扩展扫描 — 覆盖原 audit_crosref_deadfiles.ps1 未覆盖的范围
.DESCRIPTION
  1. scripts/ 引用扫描：根级 scripts/ 目录中的脚本在哪些 SKILL.md 中被引用
  2. assets/ 引用扫描：assets/ 内容是否被对应 SKILL.md 引用
  3. 断裂引用扫描：eferences/ 拼写错误、../ 路径错位等
  4. references/ 中的非 .md 文件扫描
  5. README.md 占位文件清单
.PARAMETER Path
  仓库根目录，默认当前目录
.PARAMETER ReportPath
  CSV 报告输出路径
#>

param(
  [string]$Path = (Get-Location).Path,
  [string]$ReportPath = ""
)

Set-StrictMode -Version Latest

# ── 1. scripts/ 引用扫描 ──────────────────────────────────────────────
Write-Host "`n── [1/5] scripts/ 引用扫描 ──" -ForegroundColor Cyan

$scriptsDir = Join-Path $Path "scripts"
$ScriptResults = @()
if (Test-Path $scriptsDir) {
  $allScripts = Get-ChildItem "$scriptsDir\*" -File | Where-Object { $_.Extension -in '.ps1','.py','.mjs','.js','.sh' }
  Write-Host "  根级 scripts/ 共 $($allScripts.Count) 个脚本文件"

  # 收集所有 SKILL.md
  $allSkillFiles = Get-ChildItem -Recurse -Path $Path -Filter "SKILL.md" -File |
    Where-Object { $_.FullName -notmatch '\\node_modules\\' -and $_.FullName -notmatch '\\.git\\' }

  foreach ($script in $allScripts) {
    $scriptName = $script.Name
    $scriptRel = [System.IO.Path]::GetRelativePath($Path, $script.FullName)
    $refBySkills = @()
    $refByLines = @()

    foreach ($sf in $allSkillFiles) {
      $content = Get-Content $sf.FullName -Raw -ErrorAction SilentlyContinue
      if (-not $content) { continue }
      # 搜索脚本文件名（精确匹配）
      if ($content -match [regex]::Escape($scriptName)) {
        $relPath = [System.IO.Path]::GetRelativePath($Path, $sf.FullName)
        $refBySkills += $relPath
      }
      # 也搜 scripts/xxx 模式
      if ($content -match [regex]::Escape("scripts/$scriptName")) {
        $relPath = [System.IO.Path]::GetRelativePath($Path, $sf.FullName)
        if ($relPath -notin $refBySkills) { $refBySkills += $relPath }
      }
    }

    $ScriptResults += [PSCustomObject]@{
      ScanCategory = "scripts"
      FilePath     = $scriptRel
      FileSize     = $script.Length
      RefCount     = $refBySkills.Count
      RefBySkills  = ($refBySkills -join "; ")
      Status       = if ($refBySkills.Count -eq 0) { "unreferenced" } else { "referenced" }
    }
  }
}

$unrefScripts = ($ScriptResults | Where-Object Status -eq 'unreferenced').Count
$refScripts = ($ScriptResults | Where-Object Status -eq 'referenced').Count
Write-Host "  scripts/ 引用: $refScripts 已引用, $unrefScripts 未引用" -ForegroundColor $(if ($unrefScripts -gt 0) { "Yellow" } else { "Green" })

# ── 2. assets/ 引用扫描 ──────────────────────────────────────────────
Write-Host "`n── [2/5] assets/ 引用扫描 ──" -ForegroundColor Cyan

$AssetResults = @()
$allAssetsDirs = Get-ChildItem -Recurse -Path $Path -Directory -Filter "assets" |
  Where-Object { $_.FullName -notmatch '\\node_modules\\' -and $_.FullName -notmatch '\\.git\\' }

foreach ($ad in $allAssetsDirs) {
  $assetFiles = Get-ChildItem $ad.FullName -File
  $skillDir = Split-Path $ad.Parent.FullName -Leaf

  # 找对应的 SKILL.md（assets 的同级或父级）
  $possibleSkill = Join-Path $ad.Parent.FullName "SKILL.md"
  if (-not (Test-Path $possibleSkill)) {
    $possibleSkill = Join-Path (Split-Path $ad.Parent.FullName -Parent) "SKILL.md"
  }

  $skillContent = $null
  if (Test-Path $possibleSkill) {
    $skillContent = Get-Content $possibleSkill -Raw -ErrorAction SilentlyContinue
  }

  foreach ($af in $assetFiles) {
    $assetRel = [System.IO.Path]::GetRelativePath($Path, $af.FullName)
    $referenced = $false
    if ($skillContent -and $skillContent -match [regex]::Escape($af.Name)) {
      $referenced = $true
    }
    if (-not $referenced -and $skillContent -and $skillContent -match [regex]::Escape($assetRel)) {
      $referenced = $true
    }

    $AssetResults += [PSCustomObject]@{
      ScanCategory = "assets"
      FilePath     = $assetRel
      FileSize     = $af.Length
      ParentSkill  = if (Test-Path $possibleSkill) { [System.IO.Path]::GetRelativePath($Path, $possibleSkill) } else { "无对应 SKILL.md" }
      Referenced   = $referenced
      Status       = if ($referenced) { "ok" } else { "unreferenced" }
    }
  }
}

Write-Host "  assets/ 共 $($AssetResults.Count) 个文件"
$unrefAssets = ($AssetResults | Where-Object Status -eq 'unreferenced').Count
if ($unrefAssets -gt 0) {
  Write-Host "  assets/ 未引用: $unrefAssets" -ForegroundColor Yellow
  $AssetResults | Where-Object Status -eq 'unreferenced' | ForEach-Object {
    Write-Host "    UNREFERENCED: $($_.FilePath)" -ForegroundColor Yellow
  }
} else {
  Write-Host "  assets/ 全部已引用" -ForegroundColor Green
}

# ── 3. 断裂引用扫描 ──────────────────────────────────────────────
Write-Host "`n── [3/5] 断裂引用扫描 ──" -ForegroundColor Cyan

$BrokenResults = @()
$allSkillFiles = Get-ChildItem -Recurse -Path $Path -Filter "SKILL.md" -File |
  Where-Object { $_.FullName -notmatch '\\node_modules\\' -and $_.FullName -notmatch '\\.git\\' }

foreach ($sf in $allSkillFiles) {
  $content = Get-Content $sf.FullName -Raw -ErrorAction SilentlyContinue
  $relPath = [System.IO.Path]::GetRelativePath($Path, $sf.FullName)
  if (-not $content) { continue }

  # 3a. eferences/ 拼写错误（缺前导 r）
  $eferencesMatches = [regex]::Matches($content, 'eferences/')
  foreach ($m in $eferencesMatches) {
    $BrokenResults += [PSCustomObject]@{
      ScanCategory = "broken_ref"
      FilePath     = $relPath
      IssueType    = "eferences_typo"
      Detail       = "第 $($m.LineNumber) 行附近: 'eferences/' 应为 'references/'"
      Status       = "broken"
    }
  }

  # 3b. ../通用- 从题材 Wrapper 走错路径（genre/skills/xxx/SKILL.md 中引用 ../通用-）
  if ($relPath -match 'skills\\[^-]+-') {
    $wrongPathMatches = [regex]::Matches($content, '\.\./通用-')
    foreach ($m in $wrongPathMatches) {
      # 确认确实在题材 wrapper 中
      $BrokenResults += [PSCustomObject]@{
        ScanCategory = "broken_ref"
        FilePath     = $relPath
        IssueType    = "wrong_common_ref_path"
        Detail       = "第 $($m.LineNumber) 行附近: '../通用-' 应由 '../../CommonSkills/通用-' 替代"
        Status       = "broken"
      }
    }
  }
}

Write-Host "  断裂引用: $($BrokenResults.Count) 处"
if ($BrokenResults.Count -gt 0) {
  $BrokenResults | Group-Object IssueType | ForEach-Object {
    Write-Host "    $($_.Name): $($_.Count) 处" -ForegroundColor Yellow
  }
}

# ── 4. references/ 中非 .md 文件扫描 ──────────────────────────────
Write-Host "`n── [4/5] references/ 非 .md 文件扫描 ──" -ForegroundColor Cyan

$NonMdResults = @()
$allRefDirs = Get-ChildItem -Recurse -Path $Path -Directory -Filter "references" |
  Where-Object { $_.FullName -notmatch '\\node_modules\\' -and $_.FullName -notmatch '\\.git\\' }

foreach ($rd in $allRefDirs) {
  $nonMdFiles = Get-ChildItem $rd.FullName -File | Where-Object { $_.Extension -ne '.md' }
  foreach ($f in $nonMdFiles) {
    $NonMdResults += [PSCustomObject]@{
      ScanCategory = "non_md_ref"
      FilePath     = [System.IO.Path]::GetRelativePath($Path, $f.FullName)
      FileExtension = $f.Extension
      FileSize     = $f.Length
      Status       = "non_md"
    }
  }
}

Write-Host "  references/ 中非 .md 文件: $($NonMdResults.Count) 个"

# ── 5. README.md 占位文件清单 ──
Write-Host "`n── [5/5] references/ README.md 占位清单 ──" -ForegroundColor Cyan

$ReadmeResults = @()
foreach ($rd in $allRefDirs) {
  $readmeFile = Join-Path $rd.FullName "README.md"
  if (Test-Path $readmeFile) {
    $ReadmeResults += [PSCustomObject]@{
      ScanCategory = "readme_placeholder"
      FilePath     = [System.IO.Path]::GetRelativePath($Path, $readmeFile)
      FileSize     = (Get-Item $readmeFile).Length
      Status       = "placeholder"
    }
  }
}

Write-Host "  references/ 中 README.md: $($ReadmeResults.Count) 个" -ForegroundColor DarkYellow

# ── 合并输出 ──
$AllResults = $ScriptResults + $AssetResults + $BrokenResults + $NonMdResults + $ReadmeResults

if ($ReportPath) {
  $AllResults | Export-Csv -Path $ReportPath -NoTypeInformation -Encoding UTF8
  Write-Host "`n详细报告已导出: $ReportPath" -ForegroundColor Green
}

Write-Host "`n============================================" -ForegroundColor Cyan
Write-Host "   扩展扫描完成" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  scripts/ 未引用: $unrefScripts" -ForegroundColor $(if ($unrefScripts -gt 0) { "Yellow" } else { "Green" })
Write-Host "  assets/ 未引用: $unrefAssets" -ForegroundColor $(if ($unrefAssets -gt 0) { "Yellow" } else { "Green" })
Write-Host "  断裂引用: $($BrokenResults.Count)" -ForegroundColor Yellow
Write-Host "  non-md refs: $($NonMdResults.Count)" -ForegroundColor DarkYellow
Write-Host "  README占位: $($ReadmeResults.Count)" -ForegroundColor DarkYellow
Write-Host "`n完成" -ForegroundColor Green

return $AllResults
