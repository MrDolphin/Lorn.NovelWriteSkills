$LegacyBase = "D:\第二职业\进行中\网文写作\提示词"

$Mapping = @{
    "strengthen-chapter-opening" = "通用-强化章节开头"
    "strengthen-chapter-opening-hook" = "通用-强化章节开头"
    "strengthen-ending-hook" = "通用-强化章末钩子"
    "strengthen-ending-hook-next-chapter" = "通用-强化章末钩子"
    "rewrite-chapter-de-ai" = "通用-去AI味重写"
    "design-part-volume-outline" = "通用-设计分卷大纲"
    "design-total-outline" = "通用-设计总大纲"
    "design-story-facet" = "通用-设计故事面"
    "design-tech-setting" = "通用-设计故事设定"
    "design-character-bible" = "通用-设计人物传记"
    "design-unit-case-engine" = "通用-设计事件案件引擎"
    "design-master-outline" = "通用-设计总大纲"
    "design-urban-anomaly-positioning" = "通用-设计题材定位框架"
    "evaluate-qidian-urban-weird-signing" = "通用-平台签约评估框架"
    "evaluate-qidian-signing-probability" = "通用-平台签约评估框架"
    "polish-author-note" = "通用-润色作者有话说"
    "polish-author-note-reader-theater" = "通用-润色作者有话说"
    "polish-chapter-body" = "通用-正文润色"
    "polish-chapter-prose-urban-weird" = "通用-正文润色"
    "review-chapter-body" = "通用-审阅章节正文"
    "review-chapter-execution-urban-weird" = "通用-审阅章节正文"
    "review-character-bible" = "通用-审阅人物传记"
    "review-master-outline" = "通用-审阅总大纲"
    "review-part-volume-outline" = "通用-审阅分卷大纲"
    "review-tech-setting" = "通用-审阅故事设定"
    "review-total-outline" = "通用-审阅总大纲"
    "prepare-chapter-control-card" = "通用-生成章节控制卡"
    "purify-multi-platform-source-draft" = "通用-提纯多平台母稿"
    "refine-multi-platform-master-draft" = "通用-提纯多平台母稿"
    "adapt-platform-fiction" = "通用-多平台小说适配"
    "chapter-continuity-control" = "通用-管理连续性冷热线"
    "manage-continuity-line-heat" = "通用-管理连续性冷热线"
    "execute-microspace-horror-scene" = "通用-执行微空间受限场景"
    "authenticity-and-de-ai-urban-weird" = "通用-去AI味重写"
}

$LegacyDirs = @("old都市悬疑", "old异能志怪")
$count = 0

foreach ($genre in $LegacyDirs) {
    $skillsDir = Join-Path $LegacyBase $genre ".github\skills"
    if (-not (Test-Path $skillsDir)) {
        Write-Host "[$genre] No skills dir" -ForegroundColor DarkGray
        continue
    }
    $folders = Get-ChildItem $skillsDir -Directory
    Write-Host "[$genre] $($folders.Count) legacy skills" -ForegroundColor Yellow

    foreach ($f in $folders) {
        $md = Join-Path $f.FullName "SKILL.md"
        if (-not (Test-Path $md)) { continue }

        $folderName = $f.Name
        $genericName = $Mapping[$folderName]
        if (-not $genericName) {
            Write-Host "  ? $folderName (no mapping)" -ForegroundColor DarkYellow
            continue
        }

        $c = [System.IO.File]::ReadAllText($md)
        $orig = $c
        $hasSection = $c.Contains("## 对应通用 Skill")

        if (-not $hasSection) {
            $sectionContent = "`r`n## 对应通用 Skill`r`n`r`n- " + "``" + $genericName + "``"

            $fmMatch = [regex]::Match($c, "\A---\r?\n(.*?)\r?\n---", "Singleline")
            if (-not $fmMatch.Success) { Write-Host "  ! $folderName (no fm)" -ForegroundColor Red; continue }
            $afterFm = $fmMatch.Index + $fmMatch.Length
            $afterFmText = $c.Substring($afterFm)
            $h1Match = [regex]::Match($afterFmText, "^# .+", "Multiline")
            if (-not $h1Match.Success) { Write-Host "  ! $folderName (no H1)" -ForegroundColor Red; continue }
            $titleEnd = $afterFm + $h1Match.Index + $h1Match.Length

            $restAfterTitle = $c.Substring($titleEnd)
            $nextH2 = [regex]::Match($restAfterTitle, "^## ", "Multiline")
            $insertPos = if ($nextH2.Success) { $titleEnd + $nextH2.Index } else { $c.Length }

            $c = $c.Substring(0, $insertPos) + $sectionContent + $c.Substring($insertPos)
        }

        $patterns = @(
            @("必须同时加载并使用", "必须优先强制加载"),
            @("必须加载并使用", "必须优先强制加载"),
            @("明确要求加载并使用", "明确要求优先强制加载并使用")
        )
        foreach ($p in $patterns) {
            while ($c.Contains($p[0])) { $c = $c.Replace($p[0], $p[1]) }
        }

        if ($c -ne $orig) {
            [System.IO.File]::WriteAllText($md, $c)
            $action = if (-not $hasSection) { "+ added" } else { "^ upgraded" }
            Write-Host "  $action $folderName -> $genericName" -ForegroundColor Green
            $count++
        } else {
            Write-Host "  . $folderName (unchanged)" -ForegroundColor DarkGray
        }
    }
}

Write-Host "`nLegacy processed: $count files" -ForegroundColor Cyan
