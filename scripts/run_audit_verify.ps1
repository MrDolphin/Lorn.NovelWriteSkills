<#
.SYNOPSIS
  审计验证脚本 — 快速检查所有修复是否生效
#>
$ErrorActionPreference = 'SilentlyContinue'
$root = "d:\第二职业\进行中\网文写作\提示词工程"
Set-Location $root

Write-Host "`n============================================" -ForegroundColor Cyan
Write-Host "   死文件审计 — 修复验证报告" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan

# ─── P0/P1: eferences/ 清零 ───
Write-Host "`n[P0/P1] eferences/ 拼写错误清零" -ForegroundColor Yellow
$remaining = Get-ChildItem -Recurse -Filter "SKILL.md" -File | Where-Object { $_.FullName -notmatch 'node_modules|\.git' } | Where-Object { (Get-Content $_.FullName -Raw) -match '(?<!r)eferences/' }
if (-not $remaining) { Write-Host "  ✅ 全部清零 (0 处)" -ForegroundColor Green } else { Write-Host "  ❌ 剩余 $($remaining.Count) 个文件" -ForegroundColor Red; $remaining | ForEach-Object { Write-Host "     $_" } }

# ─── P4: 保真迁移要求 → 继续读取的 references ───
Write-Host "`n[P4] 保真迁移要求→继续读取的 references 重命名" -ForegroundColor Yellow
$p4list = @("补充构建素材库","多平台小说适配","管理连续性冷热线","润色作者有话说","设计分卷大纲","设计故事面","设计故事设定","设计事件案件引擎","设计题材定位框架","生成章节控制卡","提纯多平台母稿")
$ok=0; $fail=0
foreach ($s in $p4list) {
  $p = "CommonSkills/通用-$s/SKILL.md"
  $c = Get-Content $p -Raw
  if ($c -match "## 继续读取的 references") { $ok++ } else { Write-Host "  ❌ 通用-$s"; $fail++ }
}
Write-Host "  ✅ $ok 个已更新" -ForegroundColor Green
if ($fail -gt 0) { Write-Host "  ❌ $fail 个未更新" -ForegroundColor Red }

# ─── P4: 女频爱情-设计线索伏笔补引用节 ───
Write-Host "`n[P4] 女频爱情-设计线索伏笔与回收台账 补 references 节" -ForegroundColor Yellow
$c = Get-Content "女频爱情/skills/女频爱情-设计线索伏笔与回收台账/SKILL.md" -Raw
if ($c -match "继续读取的题材 references") { Write-Host "  ✅ 已补齐" -ForegroundColor Green } else { Write-Host "  ❌ 仍缺失" -ForegroundColor Red }

# ─── P2: create-genre-skill-skeletons DEAD 文件 ───
Write-Host "`n[P2] create-genre-skill-skeletons DEAD 文件补引用" -ForegroundColor Yellow
$c = Get-Content ".github/skills/create-genre-skill-skeletons/SKILL.md" -Raw
$targets = @("all-13-platform","dual-genre-output","output-platform-lossless","output-platform-migration-audit","pilot-shared-platform-lossless","pilot-shared-platform-section")
$allFound = $true
foreach ($t in $targets) { if ($c -notmatch $t) { Write-Host "  ❌ 缺少: $t"; $allFound = $false } }
if ($allFound) { Write-Host "  ✅ 全部 6 个 DEAD 文件已引用" -ForegroundColor Green }

# ─── P3: Orphan 文件引用验证 ───
Write-Host "`n[P3] Orphan 文件引用验证" -ForegroundColor Yellow
$allSf = Get-ChildItem -Recurse -Filter "SKILL.md" -File | Where-Object { $_.FullName -notmatch 'node_modules|\.git' }

# 女频爱情 wrapper 中先前缺失的 orphan 文件
$orphans = @(
  "去AI味执行清单","三级改造与工具包","AI味识别雷达",           # 去AI味重写
  "分部模板","分卷模板与章节工件",                               # 设计分卷大纲
  "示例格式与验证流程",                                          # 设计故事设定
  "心理弧线与索引规则","质量控制与验证流程",                     # 设计人物传记
  "分部与分卷审阅报告增补","分部与分卷审阅专属检查清单",        # 审阅分卷大纲
  "人物传记审阅检查清单","审阅维度说明","人物传记审阅报告增补", # 审阅人物传记
  "总纲审阅报告增补","总纲审阅专属检查清单",                    # 审阅总大纲
  "章节正文审阅检查清单","黄金三章商业诊断清单"                  # 审阅章节正文
)
$missing = @()
foreach ($o in $orphans) {
  $found = $false
  foreach ($sf in $allSf) {
    $sm = Get-Content $sf.FullName -Raw
    if ($sm -match [regex]::Escape($o)) { $found = $true; break }
  }
  if (-not $found) { $missing += $o }
}
if ($missing.Count -eq 0) { Write-Host "  ✅ 全部 $($orphans.Count) 个 orphan 文件已引用" -ForegroundColor Green }
else { Write-Host "  ❌ 仍有 $($missing.Count) 个未引用: $($missing -join ', ')" -ForegroundColor Red }

# ─── P3: 8 个输出平台 分节级补救映射 ───
Write-Host "`n[P3] 输出平台 分节级补救映射 补引用" -ForegroundColor Yellow
$outs = @("出版社版","豆瓣版","番茄版","微信订阅号版","知乎版","GoodNovel版","My Fiction版","WebNovel版")
$ok=0; $fail=0
foreach ($o in $outs) {
  $c = Get-Content "女频爱情/skills/女频爱情-输出$o/SKILL.md" -Raw
  if ($c -match "分节级补救映射") { $ok++ } else { Write-Host "  ❌ 输出$o"; $fail++ }
}
Write-Host "  ✅ $ok 个已引用" -ForegroundColor Green
if ($fail -gt 0) { Write-Host "  ❌ $fail 个缺失" -ForegroundColor Red }

# ─── P3: 正文润色 3 个文件 ───
Write-Host "`n[P3] 女频爱情-正文润色 补引用" -ForegroundColor Yellow
$c = Get-Content "女频爱情/skills/女频爱情-正文润色/SKILL.md" -Raw
$zr = @("数值双轨禁忌","增强技法","执行流程")
$ok=0
foreach ($t in $zr) { if ($c -match $t) { $ok++ } }
Write-Host "  ✅ $ok/3 已引用" -ForegroundColor Green

# ─── 女频爱情 wrapper 缺失的 references 节 ───
Write-Host "`n[补充] 女频爱情 Wrapper 新增 references 节" -ForegroundColor Yellow
$wrapperCheck = @{
  "设计分卷大纲"    = "继续读取的题材 references"
  "设计故事设定"    = "继续读取的题材 references"
  "审阅分卷大纲"    = "继续读取的题材 references"
  "审阅人物传记"    = "继续读取的题材 references"
  "审阅总大纲"      = "继续读取的题材 references"
  "设计人物传记"    = "继续读取的题材 references"
}
$ok=0
foreach ($k in $wrapperCheck.Keys) {
  $c = Get-Content "女频爱情/skills/女频爱情-$k/SKILL.md" -Raw
  if ($c -match $wrapperCheck[$k]) { $ok++ } else { Write-Host "  ❌ 女频爱情-$k" }
}
Write-Host "  ✅ $ok/$($wrapperCheck.Count) 个 Wrapper 已有 references 节" -ForegroundColor Green

Write-Host "`n============================================" -ForegroundColor Cyan
Write-Host "   验证完成" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
