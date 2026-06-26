# Fix 通用-输出今日头条版 SKILL.md
$path = "D:\第二职业\进行中\网文写作\提示词工程\CommonSkills\通用-输出今日头条版\SKILL.md"
$c = [System.IO.File]::ReadAllText($path)

# 1. Remove inline platform research section (### 1-5 subsections)
$start = $c.IndexOf("## 平台实战经验与成长建议（研究结论迁移）")
$end = $c.IndexOf("`r`n## ", $start + 5)
$oldBlock = $c.Substring($start, $end - $start)
$newBlock = "## 平台实战经验与成长建议`r`n`r`n> 详情见 references/平台实战经验与成长建议.md。包含流量池分级、互动权重、开篇要求、读者画像与常见误区等平台研究数据，执行今日头条版改写前必须读取。"
$c = $c.Replace($oldBlock, $newBlock)

# 2. Remove wrong duplicate section (历史迁移参考 with trigger words)
$start2 = $c.IndexOf("`r`n## 历史迁移参考（非默认调度）`r`n`r`n- 输出今日头条版")
$end2 = $c.IndexOf("`r`n## 何时使用", $start2)
$bad = $c.Substring($start2, $end2 - $start2)
$c = $c.Replace($bad, "`r`n")

# 3. Replace POV inline content with reference
$start3 = $c.IndexOf("`r`n## POV 选择指南（如无显式契约）")
$end3 = $c.IndexOf("`r`n## 默认输出口径", $start3)
$oldPov = $c.Substring($start3, $end3 - $start3)
$newPov = "`r`n## POV 选择指南（如无显式契约）`r`n`r`n> 详情见 references/POV选择指南.md。包含今日头条版人称适用场景分析与基线表创建说明，无上游契约时必须读取。"
$c = $c.Replace($oldPov, $newPov)

[System.IO.File]::WriteAllText($path, $c)
Write-Host "Fixed: $($c.Length) chars written"
