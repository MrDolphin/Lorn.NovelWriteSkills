# 通用-深度研究 frontmatter 标准化
$path = "D:\第二职业\进行中\网文写作\提示词工程\CommonSkills\通用-深度研究\SKILL.md"
$refDir = "D:\第二职业\进行中\网文写作\提示词工程\CommonSkills\通用-深度研究\references"

[System.IO.File]::WriteAllText("$refDir\元数据归档.md", @"
# 元数据归档

以下元数据从 `通用-深度研究` SKILL.md 的 frontmatter 中移出，以符合 skill-structure-template.instructions.md 规范。

- **原始框架**: [Deep-Research-skills](https://github.com/Weizhena/Deep-Research-skills)
- **原始 version**: 2.1.0
- **原始 license**: MIT
- **原始 allowed-tools**: Read, Write, Glob, WebSearch, Task, AskUserQuestion
- **原始 display_name_en**: deep-research-novel
- **原始 visibility**: public

本项目 fork 自 [Deep-Research-skills](https://github.com/Weizhena/Deep-Research-skills)，改造为小说写作专用版本。
"@)

$c = [System.IO.File]::ReadAllText($path)

# Find frontmatter closing
$endIdx = $c.LastIndexOf("---`r`nuser-invocable")
$bodyStart = $c.IndexOf("`r`n", $endIdx + 3) + 2
$body = $c.Substring($bodyStart)

# Strip leading blank lines from body
$body = $body.TrimStart("`r`n ")

# New frontmatter
$fm = @"
---
name: 通用-深度研究
description: "专用于小说写作的结构化深度研究 Skill。支持对题材趋势、平台生态、专业知识、场景环境、人物原型、写作技法、读者市场等研究域，执行'大纲生成→并行深搜→报告输出'的全流程深度调研。关键词：深度研究、写作研究、题材调研、平台研究。"
argument-hint: "研究什么课题？例如：'起点中文网都市悬疑题材2025-2026趋势'。可选指定研究域：题材趋势/平台生态/专业知识/场景环境/人物原型/写作技法/读者市场。"
user-invocable: true
---

> 原始框架基于 [Deep-Research-skills](https://github.com/Weizhena/Deep-Research-skills)，改造为小说写作专用版本。原始元数据（version/display_name/allowed-tools 等）已归档至 references/元数据归档.md。

"@

$newContent = $fm + $body

# Externalize 输出示例
$s2 = $newContent.IndexOf("`r`n## 输出示例")
$e2 = $newContent.IndexOf("`r`n## 致谢", $s2 + 5)
if ($s2 -ge 0 -and $e2 -gt $s2) {
  $sec = $newContent.Substring($s2, $e2 - $s2)
  [System.IO.File]::WriteAllText("$refDir\输出示例.md", "# 输出示例`r`n`r`n> 本文件是 通用-深度研究 的支撑数据，由 SKILL.md 外化所得。`r`n$sec")
  $short = "`r`n## 输出示例`r`n`r`n> 详见 references/输出示例.md。包含调研产出目录结构及落盘路径示例。`r`n"
  $newContent = $newContent.Replace($sec, $short)
}

# Remove 致谢
$s3 = $newContent.IndexOf("`r`n## 致谢")
if ($s3 -ge 0) {
  $sec3 = $newContent.Substring($s3)
  [System.IO.File]::WriteAllText("$refDir\致谢与归属.md", "# 致谢与归属`r`n`r`n> 本文件是 通用-深度研究 的原始致谢，由 SKILL.md 外化所得。`r`n$sec3")
  $newContent = $newContent.Substring(0, $s3)
}

[System.IO.File]::WriteAllText($path, $newContent)
Write-Host "Written: $($newContent.Length) chars"
