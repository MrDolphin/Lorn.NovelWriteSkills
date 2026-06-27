# Fix remaining dead reference files
$repo = "D:\第二职业\进行中\网文写作\提示词工程"

$fixes = @(
    @{sm="CommonSkills\通用-正文润色\SKILL.md"; ref="七猫专栏阅读性价比与手机端适配增补.md"; desc="七猫专栏阅读性价比与手机端适配增补"}
    @{sm="CommonSkills\通用-正文润色\SKILL.md"; ref="技术描写可视化规则.md"; desc="技术描写可视化规则"}
    @{sm="CommonSkills\通用-创建小说正文\SKILL.md"; ref="拼章检查卡_开头中段章末与钩子链复核.md"; desc="拼章检查卡"}
    @{sm="CommonSkills\通用-创建小说正文\SKILL.md"; ref="三阶段骨架扩写拼合_体裁与扩字补编.md"; desc="三阶段骨架扩写拼合"}
    @{sm="CommonSkills\通用-设计线索伏笔与回收台账\SKILL.md"; ref="道具呼应弧线与出场追踪.md"; desc="道具呼应弧线与出场追踪"}
)

foreach ($f in $fixes) {
    $sm = Join-Path $repo $f.sm
    $c = Get-Content $sm -Raw
    $orig = $c

    # Find the ## 继续读取的 references section
    $refIdx = $c.IndexOf("## 继续读取的 references")
    if ($refIdx -lt 0) { Write-Host "NO SECTION: $($f.sm)"; continue }

    # Find end of this section (next ## heading or end of file)
    $secEnd = $c.IndexOf("`r`n## ", $refIdx + 10)
    if ($secEnd -lt 0) { $secEnd = $c.Length }

    # Check if this ref already exists
    if ($c.Substring($refIdx, $secEnd - $refIdx) -match [regex]::Escape($f.ref)) {
        Write-Host "ALREADY EXISTS: $($f.ref)"; continue
    }

    # Insert the new line before the section end
    $before = $c.Substring(0, $secEnd)
    $after = $c.Substring($secEnd)
    # Backtick format for markdown inline code
    $tick = [char]96  # backtick
    $newLine = "`r`n- ${tick}references/$($f.ref)${tick} — $($f.desc)"
    $newC = $before + $newLine + $after

    if ($newC -ne $c) {
        [System.IO.File]::WriteAllText($sm, $newC)
        Write-Host "FIXED: $($f.sm) + $($f.ref)"
    } else {
        Write-Host "NO CHANGE: $($f.sm) - $($f.ref)"
    }
}

Write-Host "=== Done ==="
