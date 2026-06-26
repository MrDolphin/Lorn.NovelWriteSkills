$SkillDir = "D:\第二职业\进行中\网文写作\提示词工程\异能志怪\skills\异能志怪-审阅章节正文"
$SkillMd = Join-Path $SkillDir "SKILL.md"
$RefDir = Join-Path $SkillDir "references"

$c = Get-Content $SkillMd -Raw

# 1. 本Skill的核心任务 → references/
$s1 = $c.IndexOf("`r`n## 本 Skill 的核心任务")
$e1 = $c.IndexOf("`r`n## 审阅输出的实际目标", $s1 + 5)
if ($s1 -ge 0 -and $e1 -gt $s1) {
  $sec1 = $c.Substring($s1, $e1 - $s1)
  $ref1 = "# 本Skill核心任务`r`n`r`n> 本文件是 异能志怪-审阅章节正文 的支撑数据，由 SKILL.md 外化所得。`r`n$sec1"
  $sec1 | Set-Content "$RefDir\本Skill核心任务.md" -Encoding UTF8
  $short1 = "`r`n## 本 Skill 的核心任务`r`n`r`n> 详见 references/本Skill核心任务.md。含10项异能志怪章节审阅检查项。`r`n"
  $c = $c.Replace($sec1, $short1)
  Write-Host "1. 核心任务 → references/"
}

# 2. 审阅输出的实际目标 → references/
$s2 = $c.IndexOf("`r`n## 审阅输出的实际目标")
$e2 = $c.IndexOf("`r`n## 工作文件与读者层边界", $s2 + 5)
if ($s2 -ge 0 -and $e2 -gt $s2) {
  $sec2 = $c.Substring($s2, $e2 - $s2)
  $ref2 = "# 审阅输出实际目标`r`n`r`n> 本文件是 异能志怪-审阅章节正文 的支撑数据，由 SKILL.md 外化所得。`r`n$sec2"
  $sec2 | Set-Content "$RefDir\审阅输出实际目标.md" -Encoding UTF8
  $short2 = "`r`n## 审阅输出的实际目标`r`n`r`n> 详见 references/审阅输出实际目标.md。含读者结论与工程结论双层输出要求。`r`n"
  $c = $c.Replace($sec2, $short2)
  Write-Host "2. 审阅输出目标 → references/"
}

# 3. 执行顺序 → references/
$s3 = $c.IndexOf("`r`n## 执行顺序")
$e3 = $c.IndexOf("`r`n## 与其他 Skill", $s3 + 5)
if ($s3 -ge 0 -and $e3 -gt $s3) {
  $sec3 = $c.Substring($s3, $e3 - $s3)
  $ref3 = "# 执行顺序`r`n`r`n> 本文件是 异能志怪-审阅章节正文 的支撑数据，由 SKILL.md 外化所得。`r`n$sec3"
  $sec3 | Set-Content "$RefDir\执行顺序.md" -Encoding UTF8
  $short3 = "`r`n## 执行顺序`r`n`r`n> 详见 references/执行顺序.md。含7步审阅流程。`r`n"
  $c = $c.Replace($sec3, $short3)
  Write-Host "3. 执行顺序 → references/"
}

# Remove duplicate ## 强制要求 section (the second one after references)
$firstFm = $c.IndexOf("## 强制要求")
$secondFm = $c.IndexOf("## 强制要求", $firstFm + 20)
if ($secondFm -ge 0) {
  # Find end of this section (next ## heading)
  $endFm = $c.IndexOf("`r`n## ", $secondFm + 15)
  if ($endFm -ge 0) {
    $dupFm = $c.Substring($secondFm, $endFm - $secondFm)
    $c = $c.Replace($dupFm, "")
    Write-Host "4. Removed duplicate ## 强制要求"
  }
}

$c | Set-Content $SkillMd -Encoding UTF8
Write-Host "=== Done ==="
