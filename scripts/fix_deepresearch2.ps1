$path = "D:\第二职业\进行中\网文写作\提示词工程\CommonSkills\通用-深度研究\SKILL.md"
$lines = Get-Content $path
$lastH1 = -1
for ($i = 0; $i -lt $lines.Count; $i++) {
  if ($lines[$i] -eq '# 通用-深度研究') { $lastH1 = $i }
}
Write-Host "Last H1 at line: $lastH1 of $($lines.Count) total"
$bodyLines = $lines[$lastH1..($lines.Count-1)]
$fm = @("---", 'name: 通用-深度研究', 'description: "专用于小说写作的结构化深度研究 Skill。支持对题材趋势、平台生态、专业知识、场景环境、人物原型、写作技法、读者市场等研究域，执行大纲生成→并行深搜→报告输出的全流程深度调研。关键词：深度研究、写作研究、题材调研。"', 'argument-hint: "研究什么课题？例如：起点中文网都市悬疑题材2025-2026趋势。可选指定研究域：题材趋势/平台生态/专业知识/场景环境/人物原型/写作技法/读者市场。"', 'user-invocable: true', "---", "")
$result = $fm + $bodyLines
$result | Set-Content $path -Encoding UTF8
Write-Host "Written: $($result.Count) lines"
