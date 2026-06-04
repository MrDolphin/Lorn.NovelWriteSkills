$skills = @(
    @{File="d:\Users\lorns\OneDrive\第二职业\网文写作\提示词\通用skills\通用-输出新浪微博版\SKILL.md"; Platform="新浪微博"},
    @{File="d:\Users\lorns\OneDrive\第二职业\网文写作\提示词\通用skills\通用-输出豆瓣版\SKILL.md"; Platform="豆瓣"},
    @{File="d:\Users\lorns\OneDrive\第二职业\网文写作\提示词\通用skills\通用-输出知乎版\SKILL.md"; Platform="知乎"},
    @{File="d:\Users\lorns\OneDrive\第二职业\网文写作\提示词\通用skills\通用-输出微信订阅号版\SKILL.md"; Platform="微信"},
    @{File="d:\Users\lorns\OneDrive\第二职业\网文写作\提示词\通用skills\通用-输出出版社版\SKILL.md"; Platform="出版社"},
    @{File="d:\Users\lorns\OneDrive\第二职业\网文写作\提示词\通用skills\通用-输出My Fiction版\SKILL.md"; Platform="My Fiction"},
    @{File="d:\Users\lorns\OneDrive\第二职业\网文写作\提示词\通用skills\通用-输出GoodNovel版\SKILL.md"; Platform="GoodNovel"},
    @{File="d:\Users\lorns\OneDrive\第二职业\网文写作\提示词\通用skills\通用-输出WebNovel版\SKILL.md"; Platform="WebNovel"},
    @{File="d:\Users\lorns\OneDrive\第二职业\网文写作\提示词\通用skills\通用-输出纵横小说版\SKILL.md"; Platform="纵横"},
    @{File="d:\Users\lorns\OneDrive\第二职业\网文写作\提示词\通用skills\通用-输出小红书版\SKILL.md"; Platform="小红书"},
    @{File="d:\Users\lorns\OneDrive\第二职业\网文写作\提示词\通用skills\通用-输出今日头条版\SKILL.md"; Platform="今日头条"},
    @{File="d:\Users\lorns\OneDrive\第二职业\网文写作\提示词\通用skills\通用-输出番茄版\SKILL.md"; Platform="番茄"},
    @{File="d:\Users\lorns\OneDrive\第二职业\网文写作\提示词\通用skills\通用-输出起点中文网版\SKILL.md"; Platform="起点"}
)

foreach ($s in $skills) {
    if (-not (Test-Path $s.File)) { Write-Output "MISS: $($s.Platform)"; continue }
    $c = Get-Content $s.File -Raw -Encoding UTF8
    if ($c -match '平台模板自动发现规则') { Write-Output "SKIP: $($s.Platform)"; continue }

    $block = "`r`n## 平台模板自动发现规则`r`n`r`n"
    $block += "若当前服务的项目根目录存在 ``Agents.md``，执行$($s.Platform)版输出前必须：`r`n`r`n"
    $block += "1. 读取项目根目录的 ``Agents.md```r`n"
    $block += "2. 若 ``Agents.md`` 中注册了三类模板，按以下优先级检索：`r`n"
    $block += "   - **优先**：模板注册时 '适用平台' 字段为 ``$($s.Platform)`` 的同类型模板`r`n"
    $block += "   - **回退**：模板注册时 '适用平台' 字段为 ``默认`` 的同类型模板`r`n"
    $block += "   - **忽略**：模板注册时 '适用平台' 指向其他平台的模板（如 ``番茄``、``起点``），本轮不加载`r`n"
    $block += "3. 若检索到匹配的三类模板——读取对应路径的模板文件：`r`n"
    $block += "   - 写作研究模板：作为$($s.Platform)平台的额外平台基线约束`r`n"
    $block += "   - 作者风格模板：作为$($s.Platform)版本保留底味和文风边界的参照`r`n"
    $block += "   - 作品蓝本模板：作为章首/回报/钩子结构保真的参照`r`n"
    $block += "4. 若项目根目录不存在 ``Agents.md``，或其中未注册$($s.Platform)专属模板——回退通用默认模式，不影响正常输出`r`n"
    $block += "5. 本 Skill 的核心约束始终是：平台规则 > 安全合规 > 母稿事实 > 三模板约束。三模板是辅助，不改变平台输出规则`r`n"

    $anchor = '分节级补救映射与详细规则回填\.md'
    if ($c -match $anchor) {
        $c = $c -replace "($anchor\s*\r?\n)\s*\r?\n## 默认执行顺序", "`${1}`r`n$block`r`n## 默认执行顺序"
        Set-Content $s.File -Value $c -Encoding UTF8 -NoNewline
        Write-Output "DONE: $($s.Platform)"
    } else {
        Write-Output "SKIP: $($s.Platform) (no anchor)"
    }
}
