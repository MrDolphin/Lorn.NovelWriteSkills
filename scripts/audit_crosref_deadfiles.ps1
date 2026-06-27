<#
.SYNOPSIS
  全仓库 references/ 文件的交叉引用审计脚本
.DESCRIPTION
  检查每个 skill 目录下 references/*.md 是否被以下入口引用：
    - 自身 SKILL.md（同一目录）
    - 同题材 prompt.md
    - 同题材 sibling skill（仅输出 orphan 文件影响范围）
  最终报告分级：
    - OK: 被自身 SKILL.md 引用
    - Orphan: 未被自身引用，但在同题材范围内被引用
    - Dead: 全局零引用
.PARAMETER Path
  仓库根目录
.PARAMETER ReportPath
  CSV 报告输出路径
#>

param(
  [string]$Path = (Get-Location).Path,
  [string]$ReportPath = ""
)

Set-StrictMode -Version Latest

# ── 收集所有 skill 目录 ──────────────────────────────────────────────
$SkillDirs = @()
# CommonSkills
$cs = Join-Path $Path "CommonSkills"
if (Test-Path $cs) { Get-ChildItem "$cs/*" -Directory | Where-Object { Test-Path (Join-Path $_.FullName "SKILL.md") } | ForEach-Object { $SkillDirs += $_.FullName } }

# Genre skills
$GenreDirs = @('都市职场','都市悬疑','异能志怪','AI科幻','女频爱情','悬疑推理','赛博庞克','太空科幻')
foreach ($g in $GenreDirs) {
  $sd = Join-Path $Path $g "skills"
  if (Test-Path $sd) { Get-ChildItem "$sd/*" -Directory | Where-Object { Test-Path (Join-Path $_.FullName "SKILL.md") } | ForEach-Object { $SkillDirs += $_.FullName } }
}

# .github/skills
$gs = Join-Path $Path ".github" "skills"
if (Test-Path $gs) { Get-ChildItem "$gs/*" -Directory | Where-Object { Test-Path (Join-Path $_.FullName "SKILL.md") } | ForEach-Object { $SkillDirs += $_.FullName } }

Write-Host "Found $($SkillDirs.Count) skill directories with SKILL.md" -ForegroundColor Cyan

# ── 预读所有 SKILL.md 内容（加速后续搜索） ────────────────────────────
$AllSkillContents = @{}
$AllSkillPaths = @{}
foreach ($dir in $SkillDirs) {
  $sm = Join-Path $dir "SKILL.md"
  $c = Get-Content $sm -Raw -ErrorAction SilentlyContinue
  $AllSkillContents[$sm] = $c
  # 提取下 skill 名（用于跨引用搜索）
  $name = [System.IO.Path]::GetFileName($dir)
  $AllSkillPaths[$name] = $sm
}

# ── 结果集 ──────────────────────────────────────────────────────────
$Results = @()

# ── 主扫描 ──────────────────────────────────────────────────────────
foreach ($dir in $SkillDirs) {
  $refDir = Join-Path $dir "references"
  if (-not (Test-Path $refDir)) { continue }

  $relDir = [System.IO.Path]::GetRelativePath($Path, $dir)
  $skillDirName = Split-Path $dir -Leaf
  $smPath = Join-Path $dir "SKILL.md"
  $smContent = $AllSkillContents[$smPath]

  Get-ChildItem "$refDir/*.md" -File | ForEach-Object {
    $refFile = $_.Name
    $refRel = [System.IO.Path]::GetRelativePath($Path, $_.FullName)
    $refSize = $_.Length

    # 读取 ref 文件首行作为描述
    $refLines = Get-Content $_.FullName -TotalCount 3 -ErrorAction SilentlyContinue
    $refDesc = ""
    foreach ($l in $refLines) {
      if ($l -match '^#\s+(.+)') { $refDesc = $Matches[1]; break }
      if ($l -match '^>\s*(.+)') { $refDesc = $Matches[1]; break }
    }
    if (-not $refDesc) { $refDesc = "(无标题)" }

    # ── 检查自引用：在自身 SKILL.md 中是否被引用 ──
    $selfRef = $false
    if ($smContent -match [regex]::Escape($refFile)) {
      $selfRef = $true
    }
    # 也检查 glob 通配引用（如 references/*.md）
    if (-not $selfRef -and $smContent -match [regex]::Escape($refDir)) {
      $selfRef = $true
    }

    # ── 检查被同题材 prompt.md 引用 ──
    $promptRef = $false
    $promptFiles = @()
    # 向上找题材目录
    $parentDir = Split-Path $dir -Parent
    $genreDirName = Split-Path $parentDir -Leaf
    # 检查题材目录下的 prompts/
    $promptDir = Join-Path $parentDir "prompts"
    if (-not (Test-Path $promptDir)) { $promptDir = Join-Path $parentDir ".github" "prompts" }
    if (Test-Path $promptDir) {
      Get-ChildItem "$promptDir/*.md" -File -ErrorAction SilentlyContinue | ForEach-Object {
        $pc = Get-Content $_.FullName -Raw -ErrorAction SilentlyContinue
        if ($pc -and $pc -match [regex]::Escape($refFile)) {
          $promptRef = $true
          $promptFiles += $_.Name
        }
      }
    }

    # ── 检查被同题材 sibling skill 引用 ──
    $siblingRef = $false
    $siblingFiles = @()
    $siblingDir = Join-Path $parentDir "skills"
    if (Test-Path $siblingDir) {
      Get-ChildItem "$siblingDir/*/SKILL.md" -File -ErrorAction SilentlyContinue | ForEach-Object {
        if ($_.FullName -ne $smPath) {
          $sc = Get-Content $_.FullName -Raw -ErrorAction SilentlyContinue
          if ($sc -and $sc -match [regex]::Escape($refFile)) {
            $siblingRef = $true
            $siblingFiles += (Split-Path (Split-Path $_.FullName -Parent) -Leaf)
          }
        }
      }
    }

    # ── 检查被 CommonSkills 引用 ──
    $commonRef = $false
    $commonFiles = @()
    Get-ChildItem "$cs/*/SKILL.md" -File -ErrorAction SilentlyContinue | ForEach-Object {
      $sc = Get-Content $_.FullName -Raw -ErrorAction SilentlyContinue
      if ($sc -and $sc -match [regex]::Escape($refFile)) {
        $commonRef = $true
        $commonFiles += (Split-Path (Split-Path $_.FullName -Parent) -Leaf)
      }
    }

    # ── 判定状态 ──
    $status = "dead"
    if ($selfRef) { $status = "ok" }
    elseif ($promptRef -or $siblingRef -or $commonRef) { $status = "orphan" }

    # ── 空壳检测 ──
    $isStale = $false
    if ($refSize -lt 200) {
      $firstLine = $refLines | Select-Object -First 1
      if ($firstLine -match '待补充|待补建|待填|占位|placeholder|TODO') { $isStale = $true }
    }

    # ── SKILL.md 缺 references 节检测 ──
    # 同时匹配 "继续读取的 references" 和 "继续读取的题材 references"
    $missingRefsSection = $smContent -notmatch '##\s*继续读取的(?:题材\s+)?\s*references'

    $obj = [PSCustomObject]@{
      SkillDir      = $relDir
      RefFile        = $refFile
      RefPath        = $refRel
      RefSize        = $refSize
      RefDesc        = $refDesc
      Status         = $status
      SelfRef        = $selfRef
      PromptRef      = $promptRef
      PromptFiles    = ($promptFiles -join ";")
      SiblingRef     = $siblingRef
      SiblingFiles   = ($siblingFiles -join ";")
      CommonRef      = $commonRef
      CommonFiles    = ($commonFiles -join ";")
      IsStale        = $isStale
      MissingRefsSec = $missingRefsSection
    }
    $Results += $obj
  }
}

# ── 输出汇总 ──────────────────────────────────────────────────────────
Write-Host "`n============================================" -ForegroundColor Cyan
Write-Host "   交叉引用审计报告" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan

$total = $Results.Count
$ok = ($Results | Where-Object Status -eq 'ok').Count
$orphan = ($Results | Where-Object Status -eq 'orphan').Count
$dead = ($Results | Where-Object Status -eq 'dead').Count
$stale = ($Results | Where-Object IsStale -eq $true).Count
$missingSec = ($Results | Where-Object MissingRefsSec -eq $true | Select-Object -Unique SkillDir).Count

Write-Host "`n总计: $total reference 文件" -ForegroundColor White
Write-Host "  OK:     $ok (被自身 SKILL.md 引用)" -ForegroundColor Green
Write-Host "  Orphan: $orphan (未自引用但被同题材引用)" -ForegroundColor Yellow
Write-Host "  DEAD:   $dead (全局零引用)" -ForegroundColor Red
Write-Host "  Stale:  $stale (空壳/占位文件)" -ForegroundColor DarkYellow
Write-Host "  缺 references 节的 skill: $missingSec" -ForegroundColor Red

# ── Dead 文件明细 ──
if ($dead -gt 0) {
  Write-Host "`n── DEAD 文件明细 ──" -ForegroundColor Red
  $Results | Where-Object Status -eq 'dead' | Sort-Object SkillDir | ForEach-Object {
    Write-Host "  DEAD: $($_.RefPath)" -ForegroundColor Red
    Write-Host "    描述: $($_.RefDesc)"
    if ($_.IsStale) { Write-Host "    状态: 空壳/占位" -ForegroundColor DarkYellow }
  }
}

# ── 缺 references 节的 skill ──
if ($missingSec -gt 0) {
  Write-Host "`n── 缺 references 节的 skill 明细 ──" -ForegroundColor Red
  $Results | Where-Object MissingRefsSec -eq $true | Select-Object SkillDir -Unique | Sort-Object SkillDir | ForEach-Object {
    $rd = $_.SkillDir
    $refsInDir = @($Results | Where-Object { $_.SkillDir -eq $rd })
    $unrefCount = @($refsInDir | Where-Object Status -eq 'dead').Count
    Write-Host "  $rd ($($refsInDir.Count) refs, $unrefCount 零引用)" -ForegroundColor Yellow
  }
}

# ── Stale 文件明细 ──
if ($stale -gt 0) {
  Write-Host "`n── Stale 文件明细 ──" -ForegroundColor DarkYellow
  $Results | Where-Object IsStale -eq $true | Sort-Object SkillDir | ForEach-Object {
    Write-Host "  [$($_.RefSize)B] $($_.RefPath)" -ForegroundColor DarkYellow
  }
}

# ── CSV 导出 ──
if ($ReportPath) {
  $Results | Export-Csv -Path $ReportPath -NoTypeInformation -Encoding UTF8
  Write-Host "`n详细报告已导出: $ReportPath" -ForegroundColor Green
}

Write-Host "`n--- 完成 ---" -ForegroundColor Green
return $Results
