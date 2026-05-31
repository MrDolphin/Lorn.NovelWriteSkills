---
user-invocable: true
description: 读取调研outline，为每个item启动独立agent，从小说创作者视角进行深度调研。禁用task output。
allowed-tools: Bash, Read, Write, Glob, WebSearch, Task
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

### Step 5: 汇总报告
全部完成后输出：
- 完成数量
- 失败/不确定标记的 items
- 输出目录

## Agent 配置
- 后台执行: 是
- Task Output: 禁用（agent 完成时有明确输出文件）
- 断点续传: 是
