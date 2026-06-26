<#
.SYNOPSIS
  批量给项目中所有 SKILL.md 添加缓存分层注释
.DESCRIPTION
  扫描 CommonSkills、题材 skills、分发 skills 等所有 SKILL.md 目录，
  按节标题名称模式识别缓存层，在 frontmatter 后、Layer 2 和 Layer 3
  起始位置插入 <!-- ===== Layer N: 名称 ===== --> 注释。
  跳过头像已有注释的文件。
.PARAMETER Path
  仓库根目录
.PARAMETER WhatIf
  仅预览不写入
.PARAMETER OnlyCommonSkills
  只处理 CommonSkills
.PARAMETER OnlyGenreWrappers
  只处理题材包装层
.PARAMETER OnlyDistro
  只处理小说分发技能
#>

param(
  [string]$Path = (Get-Location).Path,
  [switch]$WhatIf,
  [switch]$OnlyCommonSkills,
  [switch]$OnlyGenreWrappers,
  [switch]$OnlyDistro
)

$log = @()

# ── 扫描根目录 ──────────────────────────────────────────────────────
$SearchRoots = @()

if (-not $OnlyGenreWrappers -and -not $OnlyDistro) {
  # 默认包含 CommonSkills
  $csDir = Join-Path $Path "CommonSkills"
  if (Test-Path $csDir) { $SearchRoots += $csDir }
}

if (-not $OnlyCommonSkills -and -not $OnlyDistro) {
  # 题材包装层
  $GenreDirs = @('都市职场', '都市悬疑', '异能志怪', 'AI科幻', '女频爱情', '悬疑推理', '赛博庞克', '太空科幻')
  foreach ($g in $GenreDirs) {
    $sd = Join-Path $Path $g "skills"
    if (Test-Path $sd) { $SearchRoots += $sd }
  }
  # AI科幻的特殊路径
  $aiSd = Join-Path $Path "AI科幻" ".github" "skills"
  if (Test-Path $aiSd) { $SearchRoots += $aiSd }
}

if (-not $OnlyCommonSkills -and -not $OnlyGenreWrappers) {
  # 小说分发技能
  $dd = Join-Path $Path "小说分发"
  if (Test-Path $dd) { $SearchRoots += $dd }
  # 内建工具技能
  $bd = Join-Path $Path ".github" "skills"
  if (Test-Path $bd) { $SearchRoots += $bd }
}

# 无搜索根时退出
if ($SearchRoots.Count -eq 0) {
  Write-Host "没有匹配的搜索根目录" -ForegroundColor Yellow
  return
}

# 层判定规则
function Get-TargetLayer {
  param([string]$Title)
  $L1 = '适用场景|触发词|核心约束|硬规则|references.*清单|本 Skill|唯一目标|默认立场|不适用|执行规则|核心原则|强制读取|本层职责|题材路由|核心观点|引言'
  $L2 = '自动发现|风格/蓝本模板|主输出平台|模板路由|POV|依赖 Skill|依赖'
  $L3 = '执行流程|工作流程|核心命令|默认执行|执行步骤|具体操作|强制要求|执行安保|检查点|禁止误判|模块|产出物|改写清单|自检|边界|诚实|不做什么|继续读取|协作路径'

  if ($Title -match $L1) { return 1 }
  if ($Title -match $L2) { return 2 }
  if ($Title -match $L3) { return 3 }
  return 3  # 默认 Layer 3
}

# ── 主扫描循环 ──────────────────────────────────────────────────────
$AllFiles = @()
foreach ($root in $SearchRoots) {
  $AllFiles += Get-ChildItem $root -Recurse -Filter "SKILL.md" -File
}

$AllFiles | ForEach-Object {
  $file = $_.FullName
  $content = Get-Content $file -Raw
  if (-not $content) { return }

  # 跳过深度研究子 skill（仅处理主 skill 和通用 skill）
  if ($file -match '通用-深度研究\\.+\\SKILL\.md$' -and $file -notmatch '通用-深度研究\\SKILL\.md$') { return }

  # 跳过头像缓存注释的文件（匹配 ==== Layer N: ==== 模式）
  if ($content -match '<!--\s*={4,}\s*Layer\s+\d+\s*:') {
    $log += [PSCustomObject]@{ File = (Split-Path $file -Leaf); Status = 'SKIP 已有注释'; Lines = 0 }
    return
  }

  # 找 frontmatter 结尾（兼容 CRLF / LF）
  if ($content -notmatch '(?s)(^---\s*\r?\n.*?\r?\n---)\r?\n(.*)') {
    $log += [PSCustomObject]@{ File = (Split-Path $file -Leaf); Status = 'SKIP 无 frontmatter'; Lines = 0 }
    return
  }

  $frontmatter = $Matches[1]
  $bodyStart   = $Matches[2]

  # 按行处理 body，记录 layer 边界
  $bodyLines = $bodyStart -split "`n"
  $newBody   = [System.Collections.Generic.List[string]]::new()
  $insertedLayers = @{}  # layer -> bool
  $inCode = $false

  # 【改动】始终在最开头插入 Layer 1（无论第一个标题是什么）
  # 跳过 body 开头的空行和 blockquote（题材路由等），在第一个非空内容前插入
  $firstContentIdx = 0
  for ($i = 0; $i -lt $bodyLines.Count; $i++) {
    if ($bodyLines[$i].Trim() -ne '') { $firstContentIdx = $i; break }
  }
  # 在第一个内容前插入 L1 注释
  for ($i = 0; $i -lt $firstContentIdx; $i++) {
    $newBody.Add($bodyLines[$i])
  }
  $newBody.Add('')
  $newBody.Add('<!-- ===== Layer 1: 永久缓存 ===== -->')
  $newBody.Add('')
  $insertedLayers[1] = $true

  # 从第一个内容行继续处理
  for ($i = $firstContentIdx; $i -lt $bodyLines.Count; $i++) {
    $line = $bodyLines[$i]
    $trimmed = $line.Trim()

    # 跳过代码块
    if ($trimmed -match '^```') { $inCode = -not $inCode }

    # 仅在非代码块中检测节标题
    if (-not $inCode -and $trimmed -match '^##\s+(.+)') {
      $title = $Matches[1]
      $layer = Get-TargetLayer $title

      # 如果当前标题属于 L2 或 L3，且该层尚未插入，则在标题前插入层注释
      if ($layer -ge 2 -and -not $insertedLayers.ContainsKey($layer)) {
        $label = switch ($layer) { 2 { '项目级缓存' } 3 { '场景缓存' } }
        # 在前面插入空行 + 注释
        if ($newBody.Count -gt 0 -and $newBody[-1] -ne '') {
          $newBody.Add('')
        }
        $newBody.Add("<!-- ===== Layer $layer`: $label ===== -->")
        $newBody.Add('')
        $insertedLayers[$layer] = $true
      }
    }

    $newBody.Add($line)
  }

  $newContent = $frontmatter + "`n" + ($newBody -join "`n")

  if ($WhatIf) {
    $layerList = ($insertedLayers.Keys | Sort-Object | ForEach-Object { "L$_" }) -join ', '
    $log += [PSCustomObject]@{ File = (Split-Path $file -Leaf); Status = "WOULD: $layerList"; Lines = ($newContent -split "`n").Count }
  } else {
    try {
      [System.IO.File]::WriteAllText($file, $newContent, [System.Text.UTF8Encoding]::new($false))
      $layerList = ($insertedLayers.Keys | Sort-Object | ForEach-Object { "L$_" }) -join ', '
      $log += [PSCustomObject]@{ File = (Split-Path $file -Leaf); Status = "OK: $layerList"; Lines = ($newContent -split "`n").Count }
    } catch {
      $log += [PSCustomObject]@{ File = (Split-Path $file -Leaf); Status = "ERR: $_"; Lines = 0 }
    }
  }
}

# ── 汇总 ──────────────────────────────────────────────────────────────
$totalProcessed = $log.Count
$totalOk = ($log | Where-Object { $_.Status -match '^OK' }).Count
$totalSkipped = ($log | Where-Object { $_.Status -match '^SKIP' }).Count
$totalErr = ($log | Where-Object { $_.Status -match '^ERR' }).Count

Write-Host "`n=== 缓存分层标注结果 ===" -ForegroundColor Cyan
Write-Host "  总扫描: $totalProcessed 个 SKILL.md"
Write-Host "  已标注 : $totalOk" -ForegroundColor Green
Write-Host "  跳过   : $totalSkipped" -ForegroundColor Gray
if ($totalErr -gt 0) { Write-Host "  错误   : $totalErr" -ForegroundColor Red }
$log | Group-Object Status | ForEach-Object {
  $c = $_.Count
  $s = $_.Name
  $color = if ($s -match '^OK') { 'Green' } elseif ($s -match '^SKIP') { 'Gray' } else { 'Yellow' }
  Write-Host "  [$c] $s" -ForegroundColor $color
}
Write-Host "--- 完成 ---" -ForegroundColor Green
