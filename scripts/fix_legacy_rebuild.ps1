param()
$dirs = @(
    "D:\第二职业\进行中\网文写作\提示词\old都市悬疑\.github\skills",
    "D:\第二职业\进行中\网文写作\提示词\old异能志怪\.github\skills"
)
$genMap = @{}
$gen = @(
    "strengthen-chapter-opening,通用-强化章节开头"
    "strengthen-chapter-opening-hook,通用-强化章节开头"
    "strengthen-ending-hook,通用-强化章末钩子"
    "strengthen-ending-hook-next-chapter,通用-强化章末钩子"
    "rewrite-chapter-de-ai,通用-去AI味重写"
    "design-part-volume-outline,通用-设计分卷大纲"
    "design-total-outline,通用-设计总大纲"
    "design-story-facet,通用-设计故事面"
    "design-tech-setting,通用-设计故事设定"
    "design-character-bible,通用-设计人物传记"
    "design-unit-case-engine,通用-设计事件案件引擎"
    "design-master-outline,通用-设计总大纲"
    "design-urban-anomaly-positioning,通用-设计题材定位框架"
    "evaluate-qidian-urban-weird-signing,通用-平台签约评估框架"
    "evaluate-qidian-signing-probability,通用-平台签约评估框架"
    "polish-author-note,通用-润色作者有话说"
    "polish-author-note-reader-theater,通用-润色作者有话说"
    "polish-chapter-body,通用-正文润色"
    "polish-chapter-prose-urban-weird,通用-正文润色"
    "review-chapter-body,通用-审阅章节正文"
    "review-chapter-execution-urban-weird,通用-审阅章节正文"
    "review-character-bible,通用-审阅人物传记"
    "review-master-outline,通用-审阅总大纲"
    "review-part-volume-outline,通用-审阅分卷大纲"
    "review-tech-setting,通用-审阅故事设定"
    "review-total-outline,通用-审阅总大纲"
    "prepare-chapter-control-card,通用-生成章节控制卡"
    "purify-multi-platform-source-draft,通用-提纯多平台母稿"
    "refine-multi-platform-master-draft,通用-提纯多平台母稿"
    "adapt-platform-fiction,通用-多平台小说适配"
    "chapter-continuity-control,通用-管理连续性冷热线"
    "manage-continuity-line-heat,通用-管理连续性冷热线"
    "execute-microspace-horror-scene,通用-执行微空间受限场景"
    "authenticity-and-de-ai-urban-weird,通用-去AI味重写"
)
foreach ($pair in $gen) { $k,$v = $pair -split ','; $genMap[$k] = $v }
$fixed = 0
foreach ($dir in $dirs) {
    if (-not (Test-Path $dir)) { continue }
    foreach ($f in (Get-ChildItem $dir -Directory)) {
        $md = Join-Path $f.FullName "SKILL.md"
        if (-not (Test-Path $md)) { continue }
        $gn = $genMap[$f.Name]
        if (-not $gn) { continue }

        $c = [System.IO.File]::ReadAllText($md)

        # Check if the backtick reference is broken (contains ## between backticks)
        if (-not ($c -match "``" + [regex]::Escape($gn) + "``")) {
            # The reference is broken, find and fix the section
            $patStart = $c.IndexOf("## 对应通用 Skill")
            $patEnd = $c.IndexOf("## ", $patStart + 5)
            if ($patStart -ge 0 -and $patEnd -gt $patStart) {
                $newSection = "## 对应通用 Skill`r`n`r`n- ``" + $gn + "```r`n`r`n## 强制要求`r`n`r`n- 命中本技能时，必须优先强制加载 ``" + $gn + "```r`n- 不得绕过 ``" + $gn + "` 另写一套平行共性规则。`r`n- 引用通用能力时只按名称引用，不写路径。"
                $c = $c.Substring(0, $patStart) + $newSection + $c.Substring($patEnd)
                [System.IO.File]::WriteAllText($md, $c)
                Write-Host "fixed $($f.Name)" -ForegroundColor Green
                $fixed++
            }
        } else {
            Write-Host "  ok $($f.Name)" -ForegroundColor DarkGray
        }
    }
}
Write-Host "Fixed: $fixed" -ForegroundColor Cyan
