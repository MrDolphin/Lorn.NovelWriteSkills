$GenreDirs = @("都市悬疑","AI科幻","都市职场","女频爱情","异能志怪","太空科幻","悬疑推理","赛博庞克")

function Repair-SkillFile {
    param([string]$FilePath)
    try {
        $c = [System.IO.File]::ReadAllText($FilePath)
        if (-not $c) { return "empty" }
        $fm = [regex]::Match($c, "\A---\r?\n(.*?)\r?\n---", "Singleline")
        if (-not $fm.Success) { return "no-frontmatter" }
        $fmBody = $fm.Groups[1].Value
        
        # Extract name from frontmatter
        $nm = [regex]::Match($fmBody, '^name:\s*''(.+?)''', "Multiline")
        if (-not $nm.Success) { $nm = [regex]::Match($fmBody, '^name:\s*(.+)', "Multiline") }
        if (-not $nm.Success) { return "no-name" }
        $skillName = $nm.Groups[1].Value.Trim()
        
        # Derive generic name
        $genericName = $null
        $prefixes = @("都市悬疑-","AI科幻-","都市职场-","女频爱情-","异能志怪-","太空科幻-","悬疑推理-","赛博庞克-")
        foreach ($p in $prefixes) {
            if ($skillName.StartsWith($p)) { $genericName = "通用-" + $skillName.Substring($p.Length); break }
        }
        if (-not $genericName) { $genericName = "通用-" + $skillName.Substring($skillName.IndexOf('-') + 1) }
        if (-not $genericName) { return "no-generic" }
        
        # Section content to insert if missing
        $sectionHeading = "## 对应通用 Skill"
        $sectionContent = "`r`n$sectionHeading`r`n`r`n- " + "``" + $genericName + "``"
        
        $result = "unchanged"
        
        if (-not $c.Contains($sectionHeading)) {
            # Find position after H1 title heading
            $afterFm = $fm.Index + $fm.Length
            $afterFmText = $c.Substring($afterFm)
            
            # Find the H1 title line
            $h1Match = [regex]::Match($afterFmText, '^# .+', "Multiline")
            if (-not $h1Match.Success) { return "no-title" }
            $titleEnd = $afterFm + $h1Match.Index + $h1Match.Length
            
            # Find next ## heading after the title
            $restAfterTitle = $c.Substring($titleEnd)
            $nextH2 = [regex]::Match($restAfterTitle, '^## ', "Multiline")
            
            if ($nextH2.Success) {
                $insertPos = $titleEnd + $nextH2.Index
            } else {
                $insertPos = $c.Length
            }
            
            $c = $c.Substring(0, $insertPos) + $sectionContent + $c.Substring($insertPos)
            $result = "added"
        }
        
        # Upgrade language strength
        $patterns = @(
            @("必须同时加载并使用", "必须优先强制加载"),
            @("必须加载并使用", "必须优先强制加载"),
            @("明确要求加载并使用", "明确要求优先强制加载并使用")
        )
        foreach ($p in $patterns) {
            while ($c.Contains($p[0])) {
                $c = $c.Replace($p[0], $p[1])
                if ($result -eq "unchanged") { $result = "upgraded" }
            }
        }
        
        [System.IO.File]::WriteAllText($FilePath, $c)
        return $result
    } catch { return "error: " + $_.Exception.Message }
}

$stats = @{added=0;upgraded=0;unchanged=0;skipped=0;errors=0}
foreach ($genre in $GenreDirs) {
    $dir = Join-Path "D:\第二职业\进行中\网文写作\提示词" $genre ".github\skills"
    if (-not (Test-Path $dir)) { Write-Host "[$genre] N/A" -f DarkGray; continue }
    $folders = Get-ChildItem $dir -Directory
    Write-Host "[$genre] $($folders.Count)" -f Yellow
    foreach ($f in $folders) {
        $md = Join-Path $f.FullName "SKILL.md"
        if (-not (Test-Path $md)) { continue }
        $r = Repair-SkillFile -FilePath $md
        $code = @{"added"="+";"upgraded"="^";"unchanged"="."}[$r]
        if (-not $code) { $code = "?"; $stats.errors++ }
        elseif ($r -eq "added") { $stats.added++ }
        elseif ($r -eq "upgraded") { $stats.upgraded++ }
        elseif ($r -eq "unchanged") { $stats.unchanged++ }
        else { $stats.errors++ }
        $clr = @{"+"="Green";"^"="Cyan";"."="DarkGray";"?"="Red"}[$code]
        Write-Host "  $code $($f.Name)" -f $clr
        if ($r -like "error*") { Write-Host "     $r" -f Red }
    }
}
Write-Host "`nAdded:$($stats.added) Upgraded:$($stats.upgraded) Unchanged:$($stats.unchanged) Errors:$($stats.errors)"