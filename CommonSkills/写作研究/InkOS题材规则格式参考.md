# InkOS 题材规则文件格式参考（Cross-Genre 吸收）

> 来源：[Narcooo/inkos/packages/core/genres/](https://github.com/Narcooo/inkos/tree/master/packages/core/genres)
> InkOS 内置的 15 个题材规则文件（xuanhuan.md、xianxia.md、urban.md、horror.md、litrpg.md、progression.md、cultivation.md、isekai.md、sci-fi.md、romantasy.md、system-apocalypse.md、dungeon-core.md、cozy.md、tower-climber.md、other.md）
>
> 证据充分性：充分 — 15 个题材规则文件构成了一个完整的题材规则体系
> 置信度：高 — 体裁规则体系可复用为题材 Skill 的标准模板结构
> 平台归属：默认口径

## InkOS 题材规则文件的通用结构

每个 InkOS 题材规则文件（`.md`）遵循以下统一结构：

### YAML Frontmatter（元数据）

```yaml
---
name: <题材中文/英文名>
id: <题材标识符>
language: zh/en          # 默认语言
chapterTypes:            # 章节类型（可空）
fatigueWords:            # 疲劳词表（可空）
numericalSystem: true/false  # 是否有数值系统
powerScaling: true/false     # 是否有战力体系
eraResearch: true/false      # 是否需要年代研究
pacingRule: <节奏规则一句话>
satisfactionTypes:       # 爽点类型（可空）
auditDimensions:         # 审计维度（可空）
---
```

### 标准内容节（按顺序）

每个题材规则文件包含以下内容节（按出现顺序）：

1. **题材禁忌（Genre Prohibitions）** — 该题材"不能做什么"的清单
2. **题材专项规则** — 命名因题材而异：
   - `数值规则`（xuanhuan — 数值系统设计规则）
   - `修炼规则`（xianxia — 修炼体系规则）
   - `System Design Rules`（litrpg — 系统设计规则）
   - `Tech Consistency Rules`（sci-fi — 技术一致性规则）
   - `Cultivation Rules`（cultivation — 修仙规则）
   - `World Transition Rules`（isekai — 穿越规则）
   - `Romance Rules`（romantasy — 爱情规则）
   - `World Rules`（system-apocalypse — 世界规则）
   - `Floor Design Rules`（tower-climber — 楼层设计规则）
   - `Non-Human POV Rules`（dungeon-core — 非人视角规则）
   - `Emotional Arc Rules`（cozy — 情绪弧线规则）
   - `年代与现实约束`（urban — 年代与现实约束）
   - `恐惧层级`（horror — 恐惧递进模型）
3. **语言铁律（Language/语言铁律）** — 该题材的语言禁区与风格约束
4. **叙事指导（Narrative Guidance/叙事指导）** — 该题材的叙事重心与结构建议
5. **节奏参考（Pacing Guidance/节奏）** — 各阶段节奏规则

### 对本仓库的价值

本仓库的题材 Skill 可借鉴此结构，在 `设计题材定位框架` 的 `references/` 中按此模板组织题材规则：

```markdown
# <题材名> 题材规则

## 题材禁忌
- ...
## <题材专项规则>
- ...
## 语言铁律
- ...
## 叙事指导
- ...
## 节奏参考
- ...
```

这种结构化的体裁规则文件可同时被以下 Skill 消费：
- `设计题材定位框架`（作为题材规则输入）
- `创建小说正文`（作为创作约束）
- `审阅章节正文`（作为审阅标准）
- `设计总大纲`（作为题材基线）
- `设计人物传记`（作为人物行为约束）

## InkOS疲劳词表概念参考

InkOS 的题材规则文件中设计了 `fatigueWords` 字段（当前为空，等待填充），这是一个值得本仓库跟进的概念：

- 每个题材应维护一份**高频疲劳词表**（如玄幻中的"暴涨""海量""难以估量"）
- 这些词在题材正文中应被限制使用频率
- 与 `通用-去AI味重写` 的"AI高频词簇"概念互补：AI高频词 + 题材疲劳词

> 建议本仓库在后续迭代中，为每个题材 Skill 的 `references/` 添加 `题材疲劳词表.md`，与 InkOS 的 fatigueWords 字段对标。
