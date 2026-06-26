<#
.SYNOPSIS
  全仓库 SKILL.md 结构合规性审计脚本
.DESCRIPTION
  扫描 CommonSkills、题材 skills、分发 skills、深度研究等所有 SKILL.md，
  输出结构化合规报告，用于追踪结构优化进度。
  返回对象列表，每个文件一行，含完整合规指标。
.PARAMETER Path
  仓库根目录，默认当前目录
.PARAMETER ReportPath
  审计报告输出路径。默认输出到终端，指定后同时写入 CSV
.PARAMETER OnlyCommonSkills
  只审计 CommonSkills（阶段 1 专用）
.PARAMETER OnlyGenreWrappers
  只审计题材包装层（阶段 4 专用）
.PARAMETER OnlyDeepResearch
  只审计深度研究子 Skill（阶段 2A 专用）
.EXAMPLE
  # 全局审计
  ./scripts/audit_skill_structure.ps1

  # 只审计 CommonSkills 并生成 CSV 报告
  ./scripts/audit_skill_structure.ps1 -OnlyCommonSkills -ReportPath "audit_report.csv"
#>

param(
  [string]$Path = (Get-Location).Path,
  [string]$ReportPath = "",
  [switch]$OnlyCommonSkills,
  [switch]$OnlyGenreWrappers,
  [switch]$OnlyDeepResearch
)

# 辅助函数：检测 YAML frontmatter 字段
function Get-FrontmatterField {
  param([string]$Content, [string]$FieldName)
  $pattern = "(?m)^$FieldName\s*:\s*(.+)$"
  if ($Content -match $pattern) {
    return $Matches[1].Trim()
  }
  return ""
}

# 辅助函数：统计 Markdown 表格行数（去掉表头分隔行）
function Count-TableDataRows {
  param([string]$Content)
  $tableCount = 0
  $tables = [regex]::Matches($Content, '(?s)\|.+\|\r?\n\|[-| ]+\|\r?\n((?:\|.+\|\r?\n?)+)')
  foreach ($table in $tables) {
    $dataRows = ($table.Groups[1].Value -split "`n") | Where-Object { $_ -match '^\|' -and $_ -notmatch '^\|[-| ]+\|$' }
    $rowCount = ($dataRows | Measure-Object).Count
    if ($rowCount -ge 10) { $tableCount++ }
  }
  # 也检测无表头分隔线的简单表格
  $simpleTables = [regex]::Matches($Content, '(?s)((?:\|.+\|\r?\n){11,})')
  foreach ($st in $simpleTables) {
    $lines = ($st.Groups[1].Value -split "`n") | Where-Object { $_ -match '^\|' }
    if (($lines | Measure-Object).Count -ge 11) { $tableCount++ }
  }
  return $tableCount
}

# 辅助函数：检测代码块
function Get-CodeBlocks {
  param([string]$Content)
  $langs = @()
  $matches = [regex]::Matches($Content, '(?m)^```(\w+)$')
  foreach ($m in $matches) { $langs += $m.Groups[1].Value }
  return ($langs | Select-Object -Unique)
}

# 辅助函数：检测图片引用
function Get-ImageRefs {
  param([string]$Content)
  $count = 0
  # ![]() 格式
  $count += [regex]::Matches($Content, '!\[.*?\]\(.*?\)').Count
  # <img 标签
  $count += [regex]::Matches($Content, '<img\s').Count
  return $count
}

# 辅助函数：计数大于30行的连续列表
function Get-LongLists {
  param([string]$Content)
  $longListCount = 0
  $lines = $Content -split "`n"
  $consecutive = 0
  foreach ($line in $lines) {
    if ($line -match '^\s*[-*+]\s' -or $line -match '^\s*\d+\.\s') {
      $consecutive++
      if ($consecutive -eq 31) { $longListCount++ }
    } else {
      $consecutive = 0
    }
  }
  return $longListCount
}

# 辅助函数：检测缓存分层注释
function Get-CacheLayerCount {
  param([string]$Content)
  $matches = [regex]::Matches($Content, '<!--\s*Layer\s+\d')
  return $matches.Count
}

# 辅助函数：获取 references/ 文件列表
function Get-RefFiles {
  param([string]$SkillDir)
  $refDir = Join-Path $SkillDir "references"
  if (Test-Path $refDir) {
    return @(Get-ChildItem $refDir -Filter "*.md" -Name)
  }
  return @()
}

# 辅助函数：检测内嵌文本中的大块(>30行连续非空行正文)
function Get-LargeTextBlocks {
  param([string]$Content)
  $lines = $Content -split "`n"
  $consecutive = 0
  $inCode = $false
  $largeBlocks = 0
  foreach ($line in $lines) {
    if ($line -match '^```') { $inCode = -not $inCode; continue }
    if ($inCode) { continue }
    if ($line -match '^\s*$' -or $line -match '^#' -or $line -match '^\|') {
      $consecutive = 0; continue
    }
    $consecutive++
    if ($consecutive -eq 31) { $largeBlocks++ }
  }
  return $largeBlocks
}

# 辅助函数：分类技能类型
function Get-SkillCategory {
  param([string]$DirPath)
  $dirName = Split-Path $DirPath -Leaf
  if ($DirPath -match 'CommonSkills') { return "CommonSkill" }
  if ($DirPath -match '小说分发') { return "Distribution" }
  if ($DirPath -match '仅用于参考') { return "External" }
  if ($DirPath -match '通用-深度研究\\[^\\]+$') { return "DeepResearch" }
  if ($DirPath -match 'vibe-writing') { return "External" }
  if ($DirPath -match '\.github\\skills' -or $DirPath -match '\\skills\\') { return "GenreWrapper" }
  return "Other"
}

# 主扫描逻辑
$results = @()
$totalFiles = 0

Get-ChildItem $Path -Recurse -Filter "SKILL.md" -File | ForEach-Object {
  $file = $_
  $totalFiles++

  # 快速计数总行数
  $content = Get-Content $_.FullName -Raw -ErrorAction SilentlyContinue
  if (-not $content) { return }

  # 跳过外部导入
  if ($file.FullName -match '\\仅用于参考\\') { return }

  $skillDir = $_.Directory.FullName
  $category = Get-SkillCategory $skillDir
  $dirName = Split-Path $skillDir -Leaf

  # 过滤
  if ($OnlyCommonSkills -and $category -ne "CommonSkill") { return }
  if ($OnlyGenreWrappers -and $category -ne "GenreWrapper") { return }
  if ($OnlyDeepResearch -and $category -ne "DeepResearch") { return }

  # Frontmatter
  $fmMatch = [regex]::Match($content, '(?s)^---\s*\n(.*?)\n---')
  $fmText = if ($fmMatch.Success) { $fmMatch.Groups[1].Value } else { "" }

  $name = Get-FrontmatterField $fmText "name"
  $desc = Get-FrontmatterField $fmText "description"
  $argHint = Get-FrontmatterField $fmText "argument-hint"
  $userInv = Get-FrontmatterField $fmText "user-invocable"
  $allowedTools = Get-FrontmatterField $fmText "allowed-tools"

  # 去除 frontmatter 后正文
  $body = if ($fmMatch.Success) { $content.Substring($fmMatch.Index + $fmMatch.Length) } else { $content }

  # 指标
  $lineCount = ($content -split "`n").Count
  $sectionCount = [regex]::Matches($content, '(?m)^##\s').Count
  $largeTableCount = Count-TableDataRows $content
  $largeListCount = Get-LongLists $body
  $largeTextCount = Get-LargeTextBlocks $body
  $codeLangs = Get-CodeBlocks $body -join ","
  $imageCount = Get-ImageRefs $body
  $cacheLayerCount = Get-CacheLayerCount $content

  # references 分析
  $refFiles = Get-RefFiles $skillDir
  $refCount = $refFiles.Count
  $hasEmptyRef = $false
  foreach ($rf in $refFiles) {
    $refContent = Get-Content (Join-Path $skillDir "references" $rf) -Raw -ErrorAction SilentlyContinue
    if ($refContent -match '待补建') { $hasEmptyRef = $true; break }
  }

  # 是否在 Layer-1 位置（前 20%）声明了 references 清单
  # 匹配三种常见节标题模式：
  #   "## 继续读取的 references"
  #   "## 保真迁移要求（强制）"
  #   "## references 强制读取清单"
  #   "## 继续读取的题材 references"
  $lines = $content -split "`n"
  $first20pct = $lines[0..[math]::Max(0, [int]($lines.Count * 0.2))]
  $refPattern = '^##\s*(继续读取的\s*)?references|^##\s*保真迁移要求|^##\s*references\s*(强制)?读?取?清?单?'
  $refMatchingLines = $first20pct | Where-Object { $_ -match $refPattern }
  $refReadDeclared = ($refMatchingLines | Measure-Object).Count -gt 0

  # 预估内联大块
  $hasLargeInline = ($largeTableCount -gt 0 -or $largeListCount -gt 0 -or $largeTextCount -gt 0)

  # 检查标题是否与 name 一致
  $h1Match = [regex]::Match($body, '(?m)^#\s+(.+)$')
  $h1MatchText = if ($h1Match.Success) { $h1Match.Groups[1].Value.Trim() } else { "" }

  # 是否题材包装层
  $isGenreWrapper = ($category -eq "GenreWrapper")
  $hasGenreRouteDecl = $body -match "通用-[0-9a-zA-Z_\-\p{Han}]+"

  $obj = [PSCustomObject]@{
    FilePath       = $file.FullName.Replace($Path, "").TrimStart('\')
    Category       = $category
    DirName        = $dirName
    Lines          = $lineCount
    Sections       = $sectionCount
    Name           = $name
    Description    = $desc
    ArgumentHint   = $argHint
    UserInvocable  = $userInv
    HasAllowedTools = if ($allowedTools) { $true } else { $false }
    LargeTables_10plus = $largeTableCount
    LargeLists_30plus   = $largeListCount
    LargeText_30plus    = $largeTextCount
    HasLargeInline = $hasLargeInline
    CodeLangs      = $codeLangs
    Images         = $imageCount
    RefCount       = $refCount
    RefFileNames   = ($refFiles -join ";")
    HasEmptyRef    = $hasEmptyRef
    CacheLayerAnnotations = $cacheLayerCount
    RefReadInFirst20pct   = $refReadDeclared
    TitleMatchesName = if ($h1MatchText -and $name -and $h1MatchText -eq $name) { $true } else { $false }
    IsGenreWrapper  = $isGenreWrapper
    HasGenreRoute   = $isGenreWrapper -and $hasGenreRouteDecl
  }
  $results += $obj
}

# 汇总
$summary = @{}
$results | Group-Object Category | ForEach-Object {
  $cat = $_.Name
  $grp = $_.Group
  $summary[$cat] = @{
    Count           = $grp.Count
    AvgLines        = [math]::Round(($grp | Measure-Object Lines -Average).Average, 0)
    TotalInline     = ($grp | Where-Object HasLargeInline).Count
    AvgRefs         = [math]::Round(($grp | Measure-Object RefCount -Average).Average, 1)
    MissingName     = ($grp | Where-Object { -not $_.Name }).Count
    HasCodeBlocks   = ($grp | Where-Object { $_.CodeLangs }).Count
  }
}

# 输出
Write-Host "`n============================================" -ForegroundColor Cyan
Write-Host "   SKILL.md 结构合规审计报告" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan

Write-Host "`n按分类汇总:" -ForegroundColor Yellow
$summary.Keys | Sort-Object | ForEach-Object {
  $s = $summary[$_]
  Write-Host "  $_ : $($s.Count) 个 | 平均 $($s.AvgLines) 行 | $($s.TotalInline) 个有内联大块 | 平均 $($s.AvgRefs) 个 references | $($s.MissingName) 个缺 name | $($s.HasCodeBlocks) 个含代码块"
}

Write-Host "`n需要重点关注的 CommonSkills:"
$results | Where-Object { $_.Category -eq "CommonSkill" -and $_.HasLargeInline } |
  Sort-Object Lines -Descending |
  ForEach-Object {
    Write-Host "  [$($_.Lines)行] $($_.FilePath) - 大表格:$($_.LargeTables_10plus) 长列表:$($_.LargeLists_30plus) 大块文本:$($_.LargeText_30plus) refs:$($_.RefCount) 缓存标注:$($_.CacheLayerAnnotations)"
  }

Write-Host "`n缺 name 字段的文件:"
$results | Where-Object { -not $_.Name } | ForEach-Object {
  Write-Host "  $($_.FilePath)"
}

Write-Host "`n含内嵌代码块的文件:"
$results | Where-Object { $_.CodeLangs } | ForEach-Object {
  Write-Host "  [$($_.CodeLangs)] $($_.FilePath)"
}

Write-Host "`n题材包装层 references 空壳:"
$results | Where-Object { $_.IsGenreWrapper -and $_.HasEmptyRef } | ForEach-Object {
  Write-Host "  $($_.FilePath)"
}

Write-Host "`nFrontmatter 缺失统计:"
$missingName = ($results | Where-Object { -not $_.Name }).Count
$missingDesc = ($results | Where-Object { -not $_.Description }).Count
$missingArgHint = ($results | Where-Object { -not $_.ArgumentHint }).Count
$missingUserInv = ($results | Where-Object { -not $_.UserInvocable }).Count
Write-Host "  缺 name: $missingName | 缺 description: $missingDesc | 缺 argument-hint: $missingArgHint | 缺 user-invocable: $missingUserInv"

$cacheOk = ($results | Where-Object { $_.RefReadInFirst20pct }).Count
$layerAnnotated = ($results | Where-Object { $_.CacheLayerAnnotations -gt 0 }).Count
Write-Host "`n缓存合规: $cacheOk/$($results.Count) 个在文件前部声明了 references 清单"
Write-Host "  Layer 标注: $layerAnnotated/$($results.Count) 个文件有缓存分层注释"

$titleOk = ($results | Where-Object { $_.TitleMatchesName }).Count
Write-Host "标题与 name 一致: $titleOk/$($results.Count)"

Write-Host "`n总计扫描: $($results.Count) 个 SKILL.md" -ForegroundColor Green

# CSV 输出
if ($ReportPath) {
  $results | Export-Csv -Path $ReportPath -NoTypeInformation -Encoding UTF8
  Write-Host "详细报告已导出: $ReportPath" -ForegroundColor Green
}

# 返回对象供管道使用
return $results
