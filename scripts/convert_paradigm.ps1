$map = @{}
$map['案件/事件真相'] = '系统危机/技术真相'
$map['案件推进'] = '系统危机推进'
$map['案件逻辑'] = '系统逻辑'
$map['证据闭环'] = '数据链闭环'
$map['证据载体'] = '数据痕载体'
$map['证据链闭环'] = '数据链闭环'
$map['证据链'] = '数据链'
$map['证据嵌入'] = '数据痕迹嵌入'
$map['证据程序'] = '数据追溯程序'
$map['证据采集'] = '数据采集'
$map['程序阻力'] = '系统阻力'
$map['程序摩擦'] = '系统摩擦'
$map['城市压迫感'] = '数字压迫感'
$map['城市现实针脚'] = '技术针脚'
$map['城市空间压迫'] = '数字空间压迫'
$map['现实压迫感'] = '技术压迫感'
$map['现实代价'] = '技术代价'
$map['现实困境'] = '技术困境'
$map['现实议题'] = '技术议题'
$map['现实针脚'] = '技术针脚'
$map['现实质感'] = '技术质感'
$map['现实锚点'] = '技术锚点'
$map['现实调研'] = '技术调研'
$map['涉案人'] = '涉事人'
$map['嫌疑人'] = '嫌疑方'
$map['作案手法'] = '异常成因模式'
$map['凶手'] = '攻击方'
$map['被害人'] = '受影响人'
$map['尸体'] = '异常痕迹'
$map['红鲱鱼'] = '算法误导'
$map['职业切口'] = '技术切口'
$map['职业视角'] = '技术视角'
$map['职业线索'] = '技术线索'
$map['职业流程'] = '技术流程'
$map['职业动作'] = '技术动作'
$map['本土民俗'] = '数字文明'
$map['刑侦推理'] = '科技推理'
$map['审讯'] = '技术质询'
$map['勘验'] = '数据提取'
$map['取证'] = '数据提取'

$files = Get-ChildItem "d:\第二职业\进行中\网文写作\提示词\AI科幻\.github" -Recurse -Include "*.md"
$count = 0
foreach ($f in $files) {
    $c = Get-Content $f.FullName -Raw
    $o = $c
    foreach ($k in $map.Keys) {
        $c = $c -replace [regex]::Escape($k), $map[$k]
    }
    if ($c -ne $o) { Set-Content $f.FullName -Value $c -NoNewline; $count++ }
}
Write-Host "Modified $count files"
$bad = Select-String "案为|业业|常常|据据|序序|实实|市市|统统|件件|关统|空空|术能|读证|动案" -Path "d:\第二职业\进行中\网文写作\提示词\AI科幻\.github\**\*.md" -SimpleMatch | Measure-Object
Write-Host "Corruption: $($bad.Count)"
