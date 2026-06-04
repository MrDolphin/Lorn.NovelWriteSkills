$platforms = @{
    '新浪微博' = '新浪微博';
    '豆瓣' = '豆瓣';
    '知乎' = '知乎';
    '微信订阅号' = '微信';
    '出版社' = '出版社';
    'My Fiction' = 'My Fiction';
    'GoodNovel' = 'GoodNovel';
    'WebNovel' = 'WebNovel';
    '纵横小说' = '纵横';
    '小红书' = '小红书';
    '今日头条' = '今日头条';
    '番茄' = '番茄';
    '起点中文网' = '起点';
}

foreach ($k in $platforms.Keys) {
    $p = $platforms[$k]
    $file = "d:\Users\lorns\OneDrive\第二职业\网文写作\提示词\通用skills\通用-输出${k}版\SKILL.md"
    if (-not (Test-Path $file)) {
        Write-Output "MISS: $k"
        continue
    }
    $c = Get-Content $file -Raw -Encoding UTF8
    if ($c -match '平台模板自动发现规则') {
        Write-Output "SKIP: $k (exists)"
        continue
    }

    $block = @"

## 平台模板自动发现规则

若当前服务的项目根目录存在 ``Agents.md``，执行${p}版输出前必须：

1. 读取项目根目录的 ``Agents.md``
2. 若 ``Agents.md`` 中注册了三类模板，按以下优先级检索：
   - **优先**：模板注册时 "适用平台" 字段为 ``${p}`` 的同类型模板
   - **回退**：模板注册时 "适用平台" 字段为 ``默认`` 的同类型模板
   - **忽略**：模板注册时 "适用平台" 指向其他平台的模板（如 ``番茄``、``起点``），本轮不加载
3. 若检索到匹配的三类模板——读取对应路径的模板文件：
   - 写作研究模板：作为${p}平台的额外平台基线约束
   - 作者风格模板：作为${p}版本保留底味和文风边界的参照
   - 作品蓝本模板：作为章首/回报/钩子结构保真的参照
4. 若项目根目录不存在 ``Agents.md``，或其中未注册${p}专属模板——回退通用默认模式，不影响正常输出
5. 本 Skill 的核心约束始终是：平台规则 > 安全合规 > 母稿事实 > 三模板约束。三模板是辅助，不改变平台输出规则

"@

    # Find the anchor pattern and insert the block
    $pattern = '(?s)(分节级补救映射与详细规则回填\.md\s*\r?\n)\s*\r?\n## 默认执行顺序'
    if ($c -match $pattern) {
        $c = $c -replace $pattern, "`${1}`r`n$block`r`n## 默认执行顺序"
        Set-Content $file -Value $c -Encoding UTF8 -NoNewline
        Write-Output "DONE: $k"
    } else {
        Write-Output "SKIP: $k (no match pattern)"
    }
}
