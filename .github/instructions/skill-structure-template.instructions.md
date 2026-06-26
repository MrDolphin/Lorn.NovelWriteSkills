---
description: "所有 SKILL.md 文件的标准结构模板。定义 CommonSkill 与 Genre Wrapper 的统一节序、缓存分层标注、references/scripts/assets 外化规范，以及结构合规检查项。适用于本项目中所有 SKILL.md 的创建、重构、审核与审计。"
name: "SKILL.md 结构模板规范"
applyTo: "**/SKILL.md"
---

# SKILL.md 结构模板规范

> 本规范是对 `skill-authoring.instructions.md`（最小结构 + 命名）和 `cache-optimization.instructions.md`（缓存分层）的结构具象化。所有 SKILL.md 应同时遵守这三份规范。

---

## 1. 核心原则

### 1.1 职责分离

| 目录/文件 | 职责 | 放什么 |
|-----------|------|--------|
| `SKILL.md` | 导航 + 调度 + 约束 | 触发词、硬规则、references 清单、执行流程 |
| `references/` | 支撑数据 | 模板、检查清单、大表格、稳定研究结论 |
| `scripts/` | 可执行自动化 | PowerShell/Python/JS 脚本 |
| `assets/` | 二进制/非文本资产 | 图片、模板文件、示例文件 |

### 1.2 缓存分层（继承 `cache-optimization.instructions.md`）

SKILL.md 各节按以下缓存层级排列：

- **Layer 1 (永久缓存)**：跨调用完全不变 — frontmatter、触发词、硬规则、references 强制读取清单
- **Layer 2 (项目级缓存)**：同项目内稳定 — 自动发现规则、POV 契约
- **Layer 3 (场景缓存)**：同任务类型内稳定 — 执行流程、模板骨架
- **Layer 4 (可变)**：不写入 SKILL.md — 由调用方传参

### 1.3 外化阈值

SKILL.md 中出现以下内容时，应外化到 `references/`：

- **大表格** (>10 行数据行) 的纯数据/参考表格
- **长清单** (>20 项的检查清单、模板字段清单)
- **完整模板/骨架**（字段定义、子步骤详表、评分维度细则）
- **稳定研究结论**（领域分类、对标矩阵、模型声明）

**不应外化的内容**：
- 执行流程的主干步骤（保持 SKILL.md 自含导航能力）
- 硬性约束和禁行项（必须在前部可见）
- references 路由清单（必须在 Layer 1 中声明）

---

## 2. CommonSkill 标准结构

### 2.1 完整模板

```markdown
---
name: 通用-{能力名}
description: "{一句话描述：触发词 + 使用场景 + 收益}"
argument-hint: "{调用提示参数}"
user-invocable: false
---

# 通用-{能力名}

> **题材路由**：{说明哪些题材场景会调用本 Skill，或本 Skill 被哪些 Genre Wrapper 路由。若无，写 "供各题材 Skill 按名称引用"。}

<!-- ===== Layer 1: 永久缓存 ===== -->

## 适用场景 / 触发词

{列出本 Skill 典型的触发场景、用户可能的提问方式。}

## 核心约束 / 硬规则

{跨调用完全不变的规则、定义、边界条件。}

## references 强制读取清单

{按重要性列出必须读取的 references/ 文件。格式：}
- `references/{文件名}.md` — {一句话说明内容}
- `../../写作研究/{文件名}.md` — {跨目录共享引用说明}

<!-- ===== Layer 2: 项目级缓存 ===== -->

## 自动发现规则

{风格/蓝本模板自动发现规则。}
{主输出平台自动发现规则（仅编排器/创作类 Skill 需要）。}

<!-- ===== Layer 3: 场景缓存 ===== -->

## 执行流程

{编号步骤序列。步骤应简明扼要，详细子步骤应外化到 references/。}

## 强制要求 / 执行安保

{必须执行的门禁检查、禁止误判完成的情形。}

## 继续读取的 references（详情）

{如果 Layer 1 的 references 清单需要进一步解释，在此展开。}

<!-- ===== Layer 4: 可变 — 不由本 SKILL.md 控制，由调用方传入 ===== -->
```

### 2.2 分类型变体

#### 平台输出 Skill（`通用-输出*版`）

额外遵守 `platform-output-skill-architecture.instructions.md` 的[缓存分层模板](../instructions/cache-optimization.instructions.md#平台输出-skill-的缓存分层模板)。

```markdown
---
name: 通用-输出{平台名}版
description: "..."
argument-hint: "..."
user-invocable: false
---

# 通用-输出{平台名}版

<!-- Layer 1 -->
## 平台定位与核心读者画像
## 平台硬规则（不可变）
## 禁行项

<!-- Layer 2 -->
## 平台模板自动发现规则
## POV 契约与连续性

<!-- Layer 3 -->
## 继续读取的 references
## 默认执行顺序
## 改写清单与自检
```

#### 深度研究子 Skill

```markdown
---
name: 通用-深度研究-{子能力名}
description: "..."
allowed-tools: Read, Write, Glob, WebSearch, Task, AskUserQuestion
user-invocable: false
---

# 通用-深度研究-{子能力名}

<!-- Layer 1 -->
## 触发方式
## 核心约束

<!-- Layer 3 -->
## 执行流程
### Step 1: ...
### Step 2: ...

## 输出定义
```

#### 分发 Skill

```markdown
---
name: 分发-{平台名}
description: "..."
argument-hint: "..."
user-invocable: true
---

# 分发-{平台名}

<!-- Layer 1 -->
## 工作目录路由规则
## 适用场景 / 不适用情形

<!-- Layer 2 -->
## 输入前置要求
### 1) 章节文件目录
### 2) 元数据来源
### 3) 分发记录来源

<!-- Layer 3 -->
## 具体操作步骤
## 回写与日志

> 内嵌脚本应提取到 `scripts/distribute-{平台名}-helper.ps1`，本文件仅引用。
```

---

## 3. Genre Wrapper（题材包装层）标准结构

```markdown
---
name: {题材名}-{能力名}
description: "本题材{能力名}的题材包装层与路由入口。路由到 通用-{能力名} 并叠加题材特有规则。"
argument-hint: "{调用提示}"
user-invocable: false  # 若非入口 Skill 则为 false
---

# {题材名}-{能力名}

> 本 Skill 是 `通用-{能力名}` 的题材包装层。
> 通用规则见 `通用-{能力名}/SKILL.md`。
> 以下仅列出本题材的特化规则。

<!-- ===== Layer 1: 永久缓存 ===== -->

## 本层职责

{题材包装层/路由层的角色说明。}

## 强制要求

- {不得绕过通用 Skill 的规则}
- {必须先加载/调用 通用-{能力名}}

## 适用场景 / 不适用情形

<!-- ===== Layer 2: 项目级缓存 ===== -->

## 题材补充规则

{题材特有的执行规则、禁行项。}

## 继续读取的 references

- `references/{题材补丁}.md` — {内容说明}
- 跨目录引用使用名称而非路径

<!-- ===== Layer 3: 场景缓存 ===== -->

## 常见触发词 / 用户说法速查

{入口 Skill 才需要的字段，纯路由层可省略。}
```

---

## 4. 外化规则

### 4.1 内容 → `references/`

判定标准（**任一满足**即应外化）：

1. 数据/模板/清单行数 > 30 行
2. 包含 2 列以上的 Markdown 表格且数据行 > 10
3. 内容是某次研究分析的完整产出，而非调度逻辑
4. 跨调用完全稳定不变，但不属于硬约束

外化操作：
1. 将完整内容写入 `references/{文件名}.md`
2. 原位置替换为：`>> 详细内容见 references/{文件名}.md`
3. 在 Layer 1 的 references 强制读取清单中添加该文件

### 4.2 脚本 → `scripts/`

判定标准（**任一满足**即应提取）：

1. 包含可独立运行的 PowerShell/Python/JS/批处理代码块
2. 代码块被 SKILL.md 描述为"运行以下命令"
3. 具有 >5 行的可执行逻辑（不含纯示例模板）

提取操作：
1. 创建 `scripts/{描述性名称}.ps1`（或 `.py`/`.mjs`），保留完整原代码
2. SKILL.md 中代码块替换为：`运行 scripts/{文件名}` + 传参说明
3. 更新 `scripts/agents.md` 注册新脚本

### 4.3 二进制资产 → `assets/`

判定标准（**任一满足**即应移至 assets）：

1. 图片（.png/.jpg/.gif/.svg）
2. 模板文件（.docx/.xlsx/.pptx）
3. 非文本的示例文件

---

## 5. Frontmatter 标准

| 字段 | CommonSkill | Genre Wrapper | 分发 Skill | 深度研究子 Skill |
|------|-------------|---------------|-----------|-----------------|
| `name` | 必填 | 必填 | 必填 | **必填**（当前缺的需补） |
| `description` | 必填 | 必填 | 必填 | 必填 |
| `argument-hint` | 建议 | 建议 | 必填 | 建议 |
| `user-invocable` | 必填（false）| 必填（false）| 必填（true）| 必填（false）|
| `allowed-tools` | 不填 | 不填 | 不填 | 按需 |

要求：
- `name` 与目录名一致
- 一级标题 `#` 与 `name` 一致
- `description` 优先使用中文
- 入口 Skill（用户可直接调用的）`user-invocable: true`

---

## 6. 结构合规检查清单

改造 SKILL.md 后逐项检查：

### 结构完整性
- [ ] frontmatter 全部必填字段齐全
- [ ] 一级标题与 `name` 一致
- [ ] 各节按缓存分层顺序排列（L1 → L2 → L3）
- [ ] 每一节都以 `##` 或 `###` 标题开头
- [ ] 无内容被切割到 references/ 后丢失（原总行数 ≤ 新 SKILL.md + 新 references/ 之和）

### 外化合规
- [ ] >30 行的稳定数据/模板块已外化到 references/
- [ ] >10 行数据行的大表格已外化到 references/
- [ ] 内嵌可运行脚本已提取到 scripts/
- [ ] 外化后原位置有明确的引用行

### 缓存合规
- [ ] Layer 1 包含了 frontmatter + 触发词 + 硬规则 + references 清单
- [ ] Layer 2 包含了自动发现规则
- [ ] Layer 3 包含了执行流程
- [ ] Layer 4（可变参数）未出现在 SKILL.md 中
- [ ] references 强制读取清单在文件前 20% 位置内

### 题材包装层专用
- [ ] 声明了对应通用 Skill（使用名称而非路径）
- [ ] 不复制通用规则
- [ ] 强制要求先加载通用 Skill
- [ ] references 使用名称引用而非路径

### 跨目录引用
- [ ] 引用其他 Skill 时使用名称（如 `通用-设计人物传记`），不是相对路径
- [ ] 引用外部写作研究时使用相对路径（如 `../../写作研究/{文件名}.md`）

---

## 7. 与既有规范的配合

| 规范 | 关系 |
|------|------|
| `skill-authoring.instructions.md` | 本规范的**上游**——命名规则、最小结构、通用-题材关系继承于此 |
| `cache-optimization.instructions.md` | 本规范的**上游**——缓存分层理论继承于此 |
| `platform-output-skill-architecture.instructions.md` | **变体来源**——平台输出 Skill 的结构以此为准 |
| `genre-asset-layout.instructions.md` | **落位指导**——题材目录内资产的放置位置以此为准 |

本规范不替代以上任何规范，仅在结构层面对其做具象化约束。
