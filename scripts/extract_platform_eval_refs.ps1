# 通用-平台签约评估框架 内容外化脚本
# 将 SKILL.md 中可外化的数据表格和方法论节拆到 references/

$SkillDir = "D:\第二职业\进行中\网文写作\提示词工程\CommonSkills\通用-平台签约评估框架"
$SkillMd = Join-Path $SkillDir "SKILL.md"
$RefDir = Join-Path $SkillDir "references"

# 读取完整 SKILL.md
$c = [System.IO.File]::ReadAllText($SkillMd)

# 1. 外化: ## 套路赛道饱和度评估 → references/套路赛道饱和度评估.md
$start1 = $c.IndexOf("`r`n## 套路赛道饱和度评估（新增）")
$end1 = $c.IndexOf("`r`n## 大纲收入公式评估诊断", $start1 + 5)
if ($start1 -ge 0 -and $end1 -gt $start1) {
  $section1 = $c.Substring($start1, $end1 - $start1)
  # 写入 references 文件
  $ref1 = "# 套路赛道饱和度评估`r`n`r`n> 本文件是 `通用-平台签约评估框架` 的支撑数据，由 SKILL.md 中外化所得。`r`n$section1"
  [System.IO.File]::WriteAllText("$RefDir\套路赛道饱和度评估.md", $ref1)
  # 替换 SKILL.md 中的内容为引用
  $short1 = "`r`n## 套路赛道饱和度评估`r`n`r`n> 详见 references/套路赛道饱和度评估.md。包含套路饱和度评判标准（高/中/低饱和/组合创新四级）、执行方式与平台错位/短剧改编专项检查。`r`n"
  $c = $c.Replace($section1, $short1)
  Write-Host "1. 套路赛道饱和度评估 → references/"
}

# 2. 外化: ## 大纲收入公式评估诊断 → references/大纲收入公式评估诊断.md
$start2 = $c.IndexOf("`r`n## 大纲收入公式评估诊断（新增）")
$end2 = $c.IndexOf("`r`n## 蒸馏产物对标签约评估", $start2 + 5)
if ($start2 -ge 0 -and $end2 -gt $start2) {
  $section2 = $c.Substring($start2, $end2 - $start2)
  $ref2 = "# 大纲收入公式评估诊断`r`n`r`n> 本文件是 `通用-平台签约评估框架` 的支撑数据，由 SKILL.md 中外化所得。`r`n$section2"
  [System.IO.File]::WriteAllText("$RefDir\大纲收入公式评估诊断.md", $ref2)
  $short2 = "`r`n## 大纲收入公式评估诊断`r`n`r`n> 详见 references/大纲收入公式评估诊断.md。包含稿费潜力四因子公式（开篇质量×付费点密度×人设经济价值×数据增长设计）及使用规则。`r`n"
  $c = $c.Replace($section2, $short2)
  Write-Host "2. 大纲收入公式评估诊断 → references/"
}

# 3. 外化: ## 【起点口径】起点数据指标与爆款分层标准 → references/
$start3 = $c.IndexOf("`r`n## 【起点口径】起点数据指标与爆款分层标准（新增）")
$end3 = $c.IndexOf("`r`n## 研究回灌补强", $start3 + 5) 
if ($start3 -ge 0 -and $end3 -gt $start3) {
  $section3 = $c.Substring($start3, $end3 - $start3)
  $ref3 = "# 起点数据指标与爆款分层标准`r`n`r`n> 本文件是 `通用-平台签约评估框架` 的支撑数据，由 SKILL.md 中外化所得。`r`n$section3"
  [System.IO.File]::WriteAllText("$RefDir\起点数据指标与爆款分层标准.md", $ref3)
  $short3 = "`r`n## 【起点口径】起点数据指标与爆款分层标准`r`n`r`n> 详见 references/起点数据指标与爆款分层标准.md。包含核心数据指标定义、爆款分层门槛（精品/大神/白金/现象级）、分阶段评判标准映射及2025-2026趋势影响。`r`n"
  $c = $c.Replace($section3, $short3)
  Write-Host "3. 起点数据指标与爆款分层标准 → references/"
}

# 4. 外化: ## 研究回灌补强 → references/研究回灌补强.md
$start4 = $c.IndexOf("`r`n## 研究回灌补强（2026）")
$end4 = $c.IndexOf("`r`n## 投稿材料模板符合性预检", $start4 + 5)
if ($start4 -ge 0 -and $end4 -gt $start4) {
  $section4 = $c.Substring($start4, $end4 - $start4)
  $ref4 = "# 研究回灌补强`r`n`r`n> 本文件是 `通用-平台签约评估框架` 的支撑数据，由 SKILL.md 中外化所得。`r`n$section4"
  [System.IO.File]::WriteAllText("$RefDir\研究回灌补强.md", $ref4)
  $short4 = "`r`n## 研究回灌补强（2026）`r`n`r`n> 详见 references/研究回灌补强.md。包含情感向项目快审硬核验、高概念降置信度规则、价值观适配检查及情绪赛道双线评估要求。`r`n"
  $c = $c.Replace($section4, $short4)
  Write-Host "4. 研究回灌补强 → references/"
}

# 5. 外化: ## 蒸馏产物对标签约评估（新增） → references/蒸馏产物对标签约评估.md
$start5 = $c.IndexOf("`r`n## 蒸馏产物对标签约评估（新增）")
$end5 = $c.IndexOf("`r`n## 【起点口径】起点术语口径", $start5 + 5)
if ($start5 -ge 0 -and $end5 -gt $start5) {
  $section5 = $c.Substring($start5, $end5 - $start5)
  $ref5 = "# 蒸馏产物对标签约评估`r`n`r`n> 本文件是 通用-平台签约评估框架 的支撑数据，由 SKILL.md 中外化所得。`r`n$section5"
  [System.IO.File]::WriteAllText("$RefDir\蒸馏产物对标签约评估.md", $ref5)
  $short5 = "`r`n## 蒸馏产物对标签约评估`r`n`r`n> 详见 references/蒸馏产物对标签约评估.md。包含蒸馏竞对双重对标法（五层对标体系）、蒸馏蓝本对标（14维度结构层映射）、蒸馏文风对标（8维度文笔层映射）、蒸馏研究对标（5维度平台约束映射）及蒸馏竞对双重对标矩阵呈现格式。`r`n"
  $c = $c.Replace($section5, $short5)
  Write-Host "5. 蒸馏产物对标签约评估 → references/"
}

# 6. 更新 ## 继续读取的 references 节
$refList = @"
## 继续读取的 references

以下 references 按目标平台加载；通用层固定加载项对所有平台生效。

**固定加载（所有平台）**：
- `references/平台签约评估维度与权重.md`
- `references/概率分段与一票否决规则.md`
- `references/平台签约评估报告模板.md`
- `references/评估模式与落盘规则.md`
- `references/投稿成熟度审阅清单.md`
- `references/平台错位诊断卡.md`
- `references/套路赛道饱和度评估.md`
- `references/大纲收入公式评估诊断.md`
- `references/研究回灌补强.md`
- `references/蒸馏产物对标签约评估.md`

**按平台条件加载**：
- 目标平台为 **起点中文网**（含 Agents.md 解析为起点或默认回退起点）：
  - `references/起点默认审核流程与硬门槛.md`
  - `references/腾讯专栏签约评估快审卡点与投稿成熟度增补.md`
  - `references/起点数据指标与爆款分层标准.md`
  - `references/起点数据指标与爆款分层标准.md`
- 目标平台为 **七猫 / 番茄**：
  - `references/七猫默认审核流程与硬门槛.md`（如存在）
  - `references/番茄默认审核流程与硬门槛.md`（如存在）
  - `references/短剧改编适配度快速评估.md`
- 目标平台为 **晋江**：
  - `references/晋江默认审核流程与硬门槛.md`（如存在）
"@

# 替换 references 节
$refStart = $c.IndexOf("`r`n## 继续读取的 references")
$refEnd = $c.IndexOf("`r`n## 完整模板执行要求", $refStart + 5)
if ($refStart -ge 0 -and $refEnd -gt $refStart) {
  $oldRef = $c.Substring($refStart, $refEnd - $refStart)
  $c = $c.Replace($oldRef, "`r`n$refList`r`n")
  Write-Host "5. references 清单已更新"
}

# 写入更新后的 SKILL.md
[System.IO.File]::WriteAllText($SkillMd, $c)
Write-Host "=== 完成 ==="
