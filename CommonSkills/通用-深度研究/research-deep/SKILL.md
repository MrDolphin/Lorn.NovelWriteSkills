---

description: 读取调研outline，为每个item启动独立agent，从小说创作者视角进行深度调研。禁用task output。
allowed-tools: Bash, Read, Write, Glob, WebSearch, Task
user-invocable: false
---

# Research Deep - 小说写作深度调研

## 触发方式
`/research-deep`

## 执行流程

### Step 1: 自动定位 Outline
在当前工作目录查找 `*/outline.yaml` 文件，读取 items 列表、research_domain、execution 配置（含 items_per_agent）。

### Step 2: 断点续传检查
- 检查 output_dir 下已完成的 JSON 文件
- 跳过已完成的 items

### Step 3: 分批执行
- 按 batch_size 分批（完成一批需要得到用户同意才可进行下一批）
- 每个 agent 负责 items_per_agent 个项目
- 启动 web-search-agent（后台并行，禁用 task output）

**参数获取**：
- `{topic}`: outline.yaml 中的 topic 字段
- `{research_domain}`: outline.yaml 中的 research_domain 字段
- `{item_name}`: item 的 name 字段
- `{item_related_info}`: item 的完整 yaml 内容（name + category + description 等）
- `{output_dir}`: outline.yaml 中 execution.output_dir（默认 `./results`）
- `{fields_path}`: `{topic}/fields.yaml` 的绝对路径
- `{output_path}`: `{output_dir}/{item_name_slug}.json` 的绝对路径（slugify 处理 item_name：空格替换为 `_`，移除特殊字符）

**硬约束**：以下 prompt 必须严格复述，仅替换 `{xxx}` 中的变量，禁止改写结构或措辞。

**Prompt 模板**：
```python
prompt = f"""## 任务
作为小说创作者的深度研究助手，调研以下对象，输出结构化 JSON。

调研课题: {topic}
研究域: {research_domain}
调研对象: {item_related_info}

## 字段定义
读取 {fields_path} 获取所有字段定义。

## 输出要求
1. 按 fields.yaml 定义的字段输出 JSON
2. 不确定的字段值标注 [不确定]
3. JSON 末尾添加 uncertain 数组，列出所有不确定的字段名
4. 所有字段值必须使用中文输出（调研过程可用英文，但最终 JSON 值为中文）
5. **尤其注意"创作可迁移"分类下的字段**：必须把研究发现翻译成小说创作者可以直接在正文、设定、大纲中使用的具体建议，不能停留在抽象总结

## 搜索策略
优先搜索以下类型的信息源（根据研究域选择侧重点）：
- 小说平台官方数据、榜单、推荐位信息
- 读者社区讨论、书评、本章说、论坛
- 行业研究报告、创作方法论文章
- 专业知识来源（技术文档、职业手册、学术论文）
- 作家访谈、创作经验分享
- 场景/环境相关的纪实报道、纪录片、实地考察文章

## 输出路径
{output_path}

## 验证
完成 JSON 输出后，运行验证脚本确保字段完整覆盖：
python {research_dir}/validate_json.py -f {fields_path} -j {output_path}
验证通过后才算完成任务。
"""
```

**One-shot 示例**（假设调研"起点中文网都市悬疑读者偏好"）：
```
## 任务
作为小说创作者的深度研究助手，调研以下对象，输出结构化 JSON。

调研课题: 起点中文网都市悬疑题材 2025-2026 趋势
研究域: 题材趋势研究
调研对象: name: 读者偏好迁移
category: 读者反馈
description: 2025-2026 年起点中文网都市悬疑题材读者的口味变化、热门元素偏好与审美迁移趋势

## 字段定义
读取 /project/起点都市悬疑趋势/fields.yaml 获取所有字段定义。

## 输出要求
1. 按 fields.yaml 定义的字段输出 JSON
2. 不确定的字段值标注 [不确定]
3. JSON 末尾添加 uncertain 数组，列出所有不确定的字段名
4. 所有字段值必须使用中文输出
5. **尤其注意"创作可迁移"分类下的字段**：必须把研究发现翻译成小说创作者可以直接在正文、设定、大纲中使用的具体建议

## 搜索策略
优先搜索以下类型的信息源：
- 起点书评区、本章说、书友圈的读者反馈
- 知乎、龙空论坛的网文读者讨论
- 行业媒体对网文读者偏好变化的分析文章
- 起点官方发布的数据报告或品类分析

## 输出路径
/project/起点都市悬疑趋势/results/读者偏好迁移.json

## 验证
完成 JSON 输出后，运行验证脚本确保字段完整覆盖：
python /project/起点都市悬疑趋势/research/validate_json.py -f /project/起点都市悬疑趋势/fields.yaml -j /project/起点都市悬疑趋势/results/读者偏好迁移.json
验证通过后才算完成任务。
```

### Step 4: 等待与监控
- 等待当前批次完成
- 启动下一批
- 显示进度

### Step 5: 汇总报告与质量检查点

全部完成后，必须输出以下**调研质量摘要**（借鉴 nuwa-skill Phase 1.5 检查点方法论），供用户确认后再进入 /research-report：

```markdown
## 调研质量摘要

| 维度 | 状态 | 说明 |
| --- | --- | --- |
| 完成条目 | N/N | |
| 不确定字段 | M 个 | [列出关键不确定字段] |
| 信息矛盾点 | K 处 | [列出主要矛盾，保留矛盾不调和] |
| 高置信度发现 | P 条 | [列出 top 3 核心发现] |
| 信息不足维度 | Q 个 | [标注缺口，诚实告知哪些问题未找到满意答案] |
| 三重验证通过率 | X% | 核心发现/参考发现/待验证线索 分布 |

### 关键信号
- **矛盾点详情**：[逐条说明，矛盾是信号而非噪音]
- **信息缺口**：[哪些想查但没查到]
- **意外发现**：[未在原始大纲中但搜索中浮现的重要信息]
```

**用户确认调研质量 OK → 进入 /research-report。**

用户觉得某维度不够 → 补充调研后再继续。

> 这个检查点的意义：调研质量决定了最终研究报告的上限。垃圾进垃圾出——在这里拦截比报告落盘后再返工成本低得多。

### Step 6: 断点记录
- 记录完成状态到 outline.yaml 的 execution 配置中
- 标记已完成/失败的 items

## 信息质量规则（Agent 须遵守）

以下规则来自 nuwa-skill 品控方法论，在对每个 item 执行深度搜索时强制遵守：

### 来源优先级
搜索结果必须遵循主 SKILL.md 中"信息来源分级与黑名单"的规定——优先使用平台官方数据、一线从业者亲述、读者一线反馈；禁用知乎匿名回答、微信公众号、百度百科等信息源黑名单中的来源。

### 矛盾保留
遇到不同来源对同一事物的描述不一致时，**并列呈现**，标注各自来源类型与可信度，不强行调和。矛盾本身就是有价值的创作信号。

### 诚实边界
每个 item 的 JSON 输出中，必须通过 `uncertain` 数组标注所有不确定的字段。不确定包括：
- 信息来自单一来源且无法交叉验证
- 信息时效性存疑（超过 2 年且未找到更新）
- 来源可信度低（自媒体、个人博客、匿名帖子）
- 搜索未覆盖到（该维度公开信息极少）

### 深度搜索要求
- 禁止只搜第 1 页就停止——最有价值的信息往往在第 2-3 页
- 对每个 item 至少使用 3 个不同的搜索查询变体
- 优先搜索"一线从业者的碎碎念"而非"官方操作手册"——前者对创作者更可写
- 后台执行: 是
- Task Output: 禁用（agent 完成时有明确输出文件）
- 断点续传: 是
