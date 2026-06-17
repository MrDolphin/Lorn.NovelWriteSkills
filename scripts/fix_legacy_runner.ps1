$m=@{}
$m["strengthen-chapter-opening"]="通用-强化章节开头"
$m["strengthen-chapter-opening-hook"]="通用-强化章节开头"
$m["strengthen-ending-hook"]="通用-强化章末钩子"
$m["strengthen-ending-hook-next-chapter"]="通用-强化章末钩子"
$m["rewrite-chapter-de-ai"]="通用-去AI味重写"
$m["design-part-volume-outline"]="通用-设计分卷大纲"
$m["design-total-outline"]="通用-设计总大纲"
$m["design-story-facet"]="通用-设计故事面"
$m["design-tech-setting"]="通用-设计故事设定"
$m["design-character-bible"]="通用-设计人物传记"
$m["design-unit-case-engine"]="通用-设计事件案件引擎"
$m["design-master-outline"]="通用-设计总大纲"
$m["design-urban-anomaly-positioning"]="通用-设计题材定位框架"
$m["evaluate-qidian-urban-weird-signing"]="通用-平台签约评估框架"
$m["evaluate-qidian-signing-probability"]="通用-平台签约评估框架"
$m["polish-author-note"]="通用-润色作者有话说"
$m["polish-author-note-reader-theater"]="通用-润色作者有话说"
$m["polish-chapter-body"]="通用-正文润色"
$m["polish-chapter-prose-urban-weird"]="通用-正文润色"
$m["review-chapter-body"]="通用-审阅章节正文"
$m["review-chapter-execution-urban-weird"]="通用-审阅章节正文"
$m["review-character-bible"]="通用-审阅人物传记"
$m["review-master-outline"]="通用-审阅总大纲"
$m["review-part-volume-outline"]="通用-审阅分卷大纲"
$m["review-tech-setting"]="通用-审阅故事设定"
$m["review-total-outline"]="通用-审阅总大纲"
$m["prepare-chapter-control-card"]="通用-生成章节控制卡"
$m["purify-multi-platform-source-draft"]="通用-提纯多平台母稿"
$m["refine-multi-platform-master-draft"]="通用-提纯多平台母稿"
$m["adapt-platform-fiction"]="通用-多平台小说适配"
$m["chapter-continuity-control"]="通用-管理连续性冷热线"
$m["manage-continuity-line-heat"]="通用-管理连续性冷热线"
$m["execute-microspace-horror-scene"]="通用-执行微空间受限场景"
$m["authenticity-and-de-ai-urban-weird"]="通用-去AI味重写"
$m["strengthen-chapter-opening-hook"]="通用-强化章节开头"
$fn="D:\第二职业\进行中\网文写作\提示词\old都市悬疑\.github\skills"
$sn="old异能志怪"
function ProcessDir($dir){
if(-not (Test-Path $dir)){return}
foreach($f in (Get-ChildItem $dir -Directory)){
$md=Join-Path $f.FullName "SKILL.md"
if(-not (Test-Path $md)){continue}
$gn=$m[$f.Name]
if(-not $gn){Write-Host "  ? $($f.Name)" -f DarkYellow; continue}
$c=[System.IO.File]::ReadAllText($md)
$o=$c
$hs=$c.Contains("## 对应通用 Skill")
if(-not $hs){
$sc="`r`n## 对应通用 Skill`r`n`r`n- " + "``" + $gn + "``"
$fm=[regex]::Match($c,"\A---\r?\n(.*?)\r?\n---","Singleline")
if(-not $fm.Success){Write-Host "  ! $($f.Name) (no fm)" -f Red; continue}
$af=$fm.Index+$fm.Length
$aft=$c.Substring($af)
$h1=[regex]::Match($aft,"^# .+","Multiline")
if(-not $h1.Success){Write-Host "  ! $($f.Name) (no H1)" -f Red; continue}
$te=$af+$h1.Index+$h1.Length
$rat=$c.Substring($te)
$n2=[regex]::Match($rat,"^## ","Multiline")
$ip=if($n2.Success){$te+$n2.Index}else{$c.Length}
$c=$c.Substring(0,$ip)+$sc+$c.Substring($ip)
}
$c=$c.Replace("必须同时加载并使用","必须优先强制加载")
$c=$c.Replace("必须加载并使用","必须优先强制加载")
$c=$c.Replace("明确要求加载并使用","明确要求优先强制加载并使用")
if($c-ne$o){[System.IO.File]::WriteAllText($md,$c)
$a=if(-not$hs){"+ added"}else{"^ upgraded"}
Write-Host "  $a $($f.Name) -> $gn" -f Green}
else{Write-Host "  . $($f.Name)" -f DarkGray}
}
}
ProcessDir "D:\第二职业\进行中\网文写作\提示词\old都市悬疑\.github\skills"
ProcessDir "D:\第二职业\进行中\网文写作\提示词\old异能志怪\.github\skills"
