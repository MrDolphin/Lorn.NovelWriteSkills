$dirs = @(
    "D:\第二职业\进行中\网文写作\提示词\old都市悬疑\.github\skills",
    "D:\第二职业\进行中\网文写作\提示词\old异能志怪\.github\skills"
)
# Build map
$m = @{}
$data = @(
    "strengthen-chapter-opening", "通用-强化章节开头"
    "strengthen-chapter-opening-hook", "通用-强化章节开头"
    "strengthen-ending-hook", "通用-强化章末钩子"
    "strengthen-ending-hook-next-chapter", "通用-强化章末钩子"
    "rewrite-chapter-de-ai", "通用-去AI味重写"
    "design-part-volume-outline", "通用-设计分卷大纲"
    "design-total-outline", "通用-设计总大纲"
    "design-story-facet", "通用-设计故事面"
    "design-tech-setting", "通用-设计故事设定"
    "design-character-bible", "通用-设计人物传记"
    "design-unit-case-engine", "通用-设计事件案件引擎"
    "design-master-outline", "通用-设计总大纲"
    "design-urban-anomaly-positioning", "通用-设计题材定位框架"
    "evaluate-qidian-urban-weird-signing", "通用-平台签约评估框架"
    "evaluate-qidian-signing-probability", "通用-平台签约评估框架"
    "polish-author-note", "通用-润色作者有话说"
    "polish-author-note-reader-theater", "通用-润色作者有话说"
    "polish-chapter-body", "通用-正文润色"
    "polish-chapter-prose-urban-weird", "通用-正文润色"
    "review-chapter-body", "通用-审阅章节正文"
    "review-chapter-execution-urban-weird", "通用-审阅章节正文"
    "review-character-bible", "通用-审阅人物传记"
    "review-master-outline", "通用-审阅总大纲"
    "review-part-volume-outline", "通用-审阅分卷大纲"
    "review-tech-setting", "通用-审阅故事设定"
    "review-total-outline", "通用-审阅总大纲"
    "prepare-chapter-control-card", "通用-生成章节控制卡"
    "purify-multi-platform-source-draft", "通用-提纯多平台母稿"
    "refine-multi-platform-master-draft", "通用-提纯多平台母稿"
    "adapt-platform-fiction", "通用-多平台小说适配"
    "chapter-continuity-control", "通用-管理连续性冷热线"
    "manage-continuity-line-heat", "通用-管理连续性冷热线"
    "execute-microspace-horror-scene", "通用-执行微空间受限场景"
    "authenticity-and-de-ai-urban-weird", "通用-去AI味重写"
)
for ($i = 0; $i -lt $data.Count; $i += 2) { $m[$data[$i]] = $data[$i+1] }

$fixed = 0
foreach ($dir in $dirs) {
    if (-not (Test-Path $dir)) { continue }
    foreach ($f in (Get-ChildItem $dir -Directory)) {
        $md = Join-Path $f.FullName "SKILL.md"
        if (-not (Test-Path $md)) { continue }
        $gn = $m[$f.Name]
        if (-not $gn) { Write-Host "  ! $($f.Name) (no mapping)" -f DarkYellow; continue }

        $c = [System.IO.File]::ReadAllText($md)
        $o = $c

        # Strategy: find "## 对应通用 Skill", then find the "legitimate" next heading
        # (skip "## 强制要求" if it exists as it was part of the corruption)
        $pos = $c.IndexOf("## 对应通用 Skill")
        if ($pos -lt 0) { Write-Host "  ? $($f.Name) (no section)" -f DarkYellow; continue }

        # Find the next ## heading that is NOT "## 强制要求" and NOT "## 对应通用 Skill"
        $searchFrom = $pos + 5
        $nextRealHeading = -1
        for ($t = 0; $t -lt 10; $t++) {
            $nh = $c.IndexOf("## ", $searchFrom)
            if ($nh -lt 0) { break }
            $rest = $c.Substring($nh, 20)
            if (-not ($rest -match "^## 强制要求|^## 对应通用 Skill")) {
                $nextRealHeading = $nh
                break
            }
            $searchFrom = $nh + 3
        }
        if ($nextRealHeading -lt 0) { Write-Host "  ! $($f.Name) (no next heading)" -f Red; continue }

        # Build clean replacement content
        $rep = "## 对应通用 Skill"
        $rep += "`r`n`r`n- ``" + $gn + "``"
        $rep += "`r`n`r`n## 强制要求"
        $rep += "`r`n`r`n- 命中本技能时，必须优先强制加载 ``" + $gn + "``"
        $rep += "`r`n- 不得绕过 ``" + $gn + "`` 另写一套平行共性规则。"
        $rep += "`r`n- 引用通用能力时只按名称引用，不写路径。"

        $c = $c.Substring(0, $pos) + $rep + "`r`n`r`n" + $c.Substring($nextRealHeading)

        if ($c -ne $o) {
            [System.IO.File]::WriteAllText($md, $c)
            Write-Host "  fixed $($f.Name)" -f Green
            $fixed++
        } else {
            Write-Host "  ok $($f.Name)" -f DarkGray
        }
    }
}
Write-Host "Fixed: $fixed files" -f Cyan
