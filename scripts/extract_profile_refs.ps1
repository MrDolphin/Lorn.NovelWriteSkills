# 通用-撰写内容简介 外化脚本
# 将 SKILL.md 中可外化的方法论节拆到 references/

$SkillDir = "D:\第二职业\进行中\网文写作\提示词工程\CommonSkills\通用-撰写内容简介"
$SkillMd = Join-Path $SkillDir "SKILL.md"
$RefDir = Join-Path $SkillDir "references"

$c = [System.IO.File]::ReadAllText($SkillMd)

# 1. 简介即开篇原则 → references/简介即开篇原则.md
$start1 = $c.IndexOf("`r`n## 简介即开篇：简介与开头的同构原则（新增）")
$end1 = $c.IndexOf("`r`n## 简介的三句法", $start1 + 5)
if ($start1 -ge 0 -and $end1 -gt $start1) {
  $s1 = $c.Substring($start1, $end1 - $start1)
  $r1 = "# 简介即开篇原则`r`n`r`n> 本文件是 通用-撰写内容简介 的支撑数据，由 SKILL.md 外化所得。`r`n$s1"
  [System.IO.File]::WriteAllText("$RefDir\简介即开篇原则.md", $r1)
  $n1 = "`r`n## 简介即开篇原则`r`n`r`n> 详见 references/简介即开篇原则.md。包含简介与开头在核心任务、交易本质、认知缺口、卖点展示等8维度的同构对照。`r`n"
  $c = $c.Replace($s1, $n1); Write-Host "1. OK"
}

# 2. 简介的三句法 → references/简介三句法.md
$start2 = $c.IndexOf("`r`n## 简介的三句法（新增——吸收自知乎开篇精华）")
$end2 = $c.IndexOf("`r`n## 简介的切片原则", $start2 + 5)
if ($start2 -ge 0 -and $end2 -gt $start2) {
  $s2 = $c.Substring($start2, $end2 - $start2)
  $r2 = "# 简介三句法`r`n`r`n> 本文件是 通用-撰写内容简介 的支撑数据，由 SKILL.md 外化所得。`r`n$s2"
  [System.IO.File]::WriteAllText("$RefDir\简介三句法.md", $r2)
  $n2 = "`r`n## 简介的三句法`r`n`r`n> 详见 references/简介三句法.md。包含三句法的疑问/情绪/代入三任务及示例。`r`n"
  $c = $c.Replace($s2, $n2); Write-Host "2. OK"
}

# 3. 简介的切片原则 → references/简介切片原则.md
$start3 = $c.IndexOf("`r`n## 简介的切片原则 vs 大纲体（新增——吸收自知乎开篇精华）")
$end3 = $c.IndexOf("`r`n## 信息差与认知缺口", $start3 + 5)
if ($start3 -ge 0 -and $end3 -gt $start3) {
  $s3 = $c.Substring($start3, $end3 - $start3)
  $r3 = "# 简介切片原则`r`n`r`n> 本文件是 通用-撰写内容简介 的支撑数据，由 SKILL.md 外化所得。`r`n$s3"
  [System.IO.File]::WriteAllText("$RefDir\简介切片原则.md", $r3)
  $n3 = "`r`n## 简介的切片原则 vs 大纲体`r`n`r`n> 详见 references/简介切片原则.md。包含大纲体与切片式的对比、切片简介的核心原则及AI搜索摘要摘录区格式。`r`n"
  $c = $c.Replace($s3, $n3); Write-Host "3. OK"
}

# 4. 信息差与认知缺口 → references/信息差与认知缺口.md
$start4 = $c.IndexOf("`r`n## 信息差与认知缺口在简介中的应用（新增）")
$end4 = $c.IndexOf("`r`n## 简介的交易本质自检", $start4 + 5)
if ($start4 -ge 0 -and $end4 -gt $start4) {
  $s4 = $c.Substring($start4, $end4 - $start4)
  $r4 = "# 信息差与认知缺口`r`n`r`n> 本文件是 通用-撰写内容简介 的支撑数据，由 SKILL.md 外化所得。`r`n$s4"
  [System.IO.File]::WriteAllText("$RefDir\信息差与认知缺口.md", $r4)
  $n4 = "`r`n## 信息差与认知缺口在简介中的应用`r`n`r`n> 详见 references/信息差与认知缺口.md。包含信息差公式及使用方法。`r`n"
  $c = $c.Replace($s4, $n4); Write-Host "4. OK"
}

# 5. 简介的交易本质自检 → references/简介交易本质自检.md
$start5 = $c.IndexOf("`r`n## 简介的交易本质自检（新增——吸收自知乎开篇精华）")
$end5 = $c.IndexOf("`r`n## 简介的 GEO 友好度自检", $start5 + 5)
if ($start5 -ge 0 -and $end5 -gt $start5) {
  $s5 = $c.Substring($start5, $end5 - $start5)
  $r5 = "# 简介交易本质自检`r`n`r`n> 本文件是 通用-撰写内容简介 的支撑数据，由 SKILL.md 外化所得。`r`n$s5"
  [System.IO.File]::WriteAllText("$RefDir\简介交易本质自检.md", $r5)
  $n5 = "`r`n## 简介的交易本质自检`r`n`r`n> 详见 references/简介交易本质自检.md。包含自检三问及判断标准。`r`n"
  $c = $c.Replace($s5, $n5); Write-Host "5. OK"
}

# 更新 references 清单
$oldRefs = $c.Substring($c.IndexOf("`r`n## 继续读取的 references"), $c.IndexOf("`r`n<!-- ===== Layer 2") - $c.IndexOf("`r`n## 继续读取的 references"))
$newRefs = @"
## 继续读取的 references

- `references/内容简介结构模板与压缩规则.md`
- `references/情境钩子与心理价值写法.md`
- `references/平台简介差异提醒.md`
- `references/简介落盘与版本管理.md`
- `references/GEO简介优化规则.md`
- `references/简介即开篇原则.md`
- `references/简介三句法.md`
- `references/简介切片原则.md`
- `references/信息差与认知缺口.md`
- `references/简介交易本质自检.md`
- `../../写作研究/GEO小说项目核心参考.md`（必读——了解 GEO 基础知识与小说四维框架）

**以下为腾讯专栏专用 references（仅在目标平台包含腾讯专栏时加载）：**
- `references/腾讯专栏简介首句与标签增补.md`
- `references/腾讯专栏简介圆桌多维增补.md`
- `references/腾讯专栏简介五要五不要增补.md`
- `references/腾讯专栏简介多编辑规范增补.md`
- `references/腾讯专栏简介三要素与职业身份具体化增补.md`
- `references/腾讯专栏简介取巧法与平台风格分类增补.md`
"@
$c = $c.Replace($oldRefs, "`r`n$newRefs`r`n")

[System.IO.File]::WriteAllText($SkillMd, $c)
Write-Host "=== Done ==="
