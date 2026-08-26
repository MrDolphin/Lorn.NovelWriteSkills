# -*- coding: utf-8 -*-
"""
voice_audit_novel.py — 作者"像不像"四指标审计（通用-作者风格进化）

用法:
  python scripts/voice_audit_novel.py --text {章节正文.md} \
      --samples {项目根}/蒸馏产物/作者风格进化/作者原声样本库.md \
      --card {项目根}/蒸馏产物/作者风格进化/作者风格画像.md \
      [--chapters 1]

指标:
  1. 原声句占比    —— 正文中与样本库原话高度相似的句子占比 (达标 >=15%)
  2. 惯用语命中率  —— 画像卡引号短语(毒舌命名/口头禅)在正文命中数 ÷ 章节数 (达标 >=1 次/章)
  3. 立场显影溯源率—— 含母题关键词的句子 占 含立场信号词句子的比例 (达标 >=80%)
  4. 风格漂移检测  —— 句长均值/长句占比/极差与网文基线偏离 (偏离 >30% 需复审)

输出: JSON + 证据式摘要。禁止手写达标结论——以本脚本输出为准。
纯标准库,无第三方依赖。Anti-Cheat: 所有指标数字必须来自本脚本。
"""

import argparse
import json
import os
import re
import sys

# Windows 控制台默认 GBK，强制 UTF-8 输出避免 UnicodeEncodeError
if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8")
    sys.stderr.reconfigure(encoding="utf-8")


def read_text(path):
    if not path or not os.path.isfile(path):
        return ""
    with open(path, "r", encoding="utf-8") as f:
        return f.read()


def extract_body(md_text):
    """提取章节正文:跳过 # 标题行;到第一个 '## ' 前的段落为正文;无二级标题时取全部非标题行"""
    lines = md_text.splitlines()
    body = []
    for line in lines:
        s = line.strip()
        if s.startswith("## "):
            break
        if s.startswith("#") or not s:
            continue
        body.append(s)
    return "\n".join(body)


def split_sentences(text):
    text = re.sub(r"\s+", "", text)
    parts = re.split(r"(?<=[。！？;；!?…])", text)
    return [p for p in parts if len(p) >= 4]


def lcs_len(a, b):
    """最长公共子串长度"""
    if not a or not b:
        return 0
    n, m = len(a), len(b)
    best = 0
    cur = [0] * m
    for i in range(n):
        prev = 0
        for j in range(m):
            t = cur[j]
            if a[i] == b[j]:
                cur[j] = prev + 1
                best = max(best, cur[j])
            else:
                cur[j] = 0
            prev = t
    return best


def load_samples(samples_text):
    """从样本库提取原话(逐字行,去重)"""
    out = []
    for line in samples_text.splitlines():
        s = line.strip()
        if s.startswith("- **原话**：") or s.startswith("- **原话**: "):
            raw = s.split("：", 1)[1] if "：" in s else s.split(":", 1)[1]
            raw = raw.strip().strip("\"“”'")
            if len(raw) >= 8:
                out.append(raw)
    return list(dict.fromkeys(out))


def load_phrases(card_text):
    """画像卡引号「」/“”内短语作为惯用词表"""
    out = []
    for m in re.findall(r"[「“]([^」”]{2,16})[」”]", card_text):
        if not re.fullmatch(r"[，。！？、\s]+", m):
            out.append(m)
    return list(dict.fromkeys(out))


def load_motifs(card_text):
    """画像卡价值母题层与显影层的关键词(含'母题'行的引号短语 + 常见母题词兜底)"""
    out = []
    in_motif = False
    for line in card_text.splitlines():
        s = line.strip()
        if s.startswith("## ") and not s.startswith("## 五"):
            if in_motif:
                break
        if s.startswith("## 五") or "母题" in s:
            in_motif = True
        if in_motif:
            out += re.findall(r"[「“]([^」”]{2,12})[」”]", s)
    out = list(dict.fromkeys(out))
    if not out:
        out = ["背叛", "公平", "代价", "信任", "尊严", "活着"]
    return out


def stance_signals():
    return ["觉得", "以为", "凭什么", "该", "不该", "应该", "恨", "怕",
            "羡慕", "嫉妒", "活该", "可笑", "荒谬", "亏", "赚", "值不值", "值吗"]


def ratio_evidence(sentences, refs):
    """返回 (命中比例, 命中的句子列表)"""
    hits = []
    for s in sentences:
        best = 0
        for r in refs:
            b = lcs_len(s, r)
            if b > best:
                best = b
        rate = best / len(s) if len(s) else 0
        if best >= 8 and rate >= 0.45:
            hits.append(s)
    ratio = len(hits) / len(sentences) if sentences else 0.0
    return ratio, hits


def main():
    ap = argparse.ArgumentParser(description="作者像不像四指标审计")
    ap.add_argument("--text", required=True, help="章节正文 md 文件")
    ap.add_argument("--samples", default="", help="作者原声样本库.md")
    ap.add_argument("--card", default="", help="作者风格画像.md")
    ap.add_argument("--chapters", type=int, default=1, help="章节数(惯用语命中率分母)")
    args = ap.parse_args()

    sentences = split_sentences(extract_body(read_text(args.text)))
    if not sentences:
        print(json.dumps({"error": "未在文件中提取到正文(前部无 '## ' 且无正文)", "file": args.text},
                         ensure_ascii=False, indent=2))
        sys.exit(1)

    report = {"file": args.text, "正文句数": len(sentences)}

    samples = load_samples(read_text(args.samples))
    if samples:
        r1, hits1 = ratio_evidence(sentences, samples)
        report["1_原声句占比"] = {"value": round(r1, 3), "达标线": 0.15,
                                  "状态": "OK" if r1 >= 0.15 else "REVIEW"}
        report["原声句证据"] = hits1[:8]
    else:
        report["1_原声句占比"] = {"value": None, "说明": "样本库为空(先采样再审计)"}

    phrases = load_phrases(read_text(args.card))
    if phrases:
        text = "".join(sentences)
        seen = [p for p in phrases if p in text]
        hit_rate = len(seen) / args.chapters if args.chapters else 0.0
        report["2_惯用语命中率"] = {"value": round(hit_rate, 3), "命中": seen,
                                     "词表": phrases[:15], "达标线": "≥1 次/章",
                                     "状态": "OK" if hit_rate >= 1.0 else "REVIEW"}
    else:
        report["2_惯用语命中率"] = {"value": None, "说明": "画像卡无引号短语(蒸馏后生效)"}

    motifs = load_motifs(read_text(args.card))
    stance_terms = stance_signals()
    stance_sents = [s for s in sentences if any(t in s for t in stance_terms)]
    traced = [s for s in stance_sents if any(t in s for t in motifs)]
    if stance_sents:
        r3 = len(traced) / len(stance_sents)
        report["3_立场显影溯源率"] = {"value": round(r3, 3), "达标线": 0.80,
                                       "立场句数": len(stance_sents),
                                       "母题词表": motifs[:12],
                                       "状态": "OK" if r3 >= 0.80 else "REVIEW"}
        report["溯源证据"] = traced[:8]
    else:
        report["3_立场显影溯源率"] = {"value": None, "说明": "未检出立场信号句"}

    lens = [len(s) for s in sentences]
    avg_len = round(sum(lens) / len(lens), 1) if lens else 0
    overlong = sum(1 for s in sentences if len(s) > 35)
    too_even = (max(lens) - min(lens) < 12) if lens else False
    body_text = "".join(sentences)
    drift = {
        "平均句长(字)": avg_len,
        "网文基线": "12-28 (低于=过碎,高于=书面腔)",
        ">35字长句占比": round(overlong / len(sentences), 2) if sentences else 0,
        "句长极差": (max(lens) - min(lens)) if lens else 0,
        "对话标签密度/千字": round(len(re.findall(r"[””]\s*[他说道问]|道[，。]", body_text)) / len(body_text) * 1000, 2) if body_text else 0,
    }
    if avg_len and (avg_len > 28 or avg_len < 12):
        drift["本书判断"] = "偏离基线(>30%):句长分布离网文区间过远,需复审"
    elif too_even:
        drift["本书判断"] = "偏离:句长过均匀,疑似模板化(AI腔信号)"
    else:
        drift["本书判断"] = "在网文区间内"
    report["4_风格漂移检测"] = drift

    print(json.dumps(report, ensure_ascii=False, indent=2))
    print("\n=== 证据摘要 ===")
    if report.get("1_原声句占比", {}).get("value") is not None:
        v = report["1_原声句占比"]["value"]
        print("  [原声句占比] {0:%} {1}".format(v, "OK" if v >= 0.15 else "REVIEW"))
    if report.get("2_惯用语命中率", {}).get("value") is not None:
        v = report["2_惯用语命中率"]["value"]
        print("  [惯用语命中] {} 次/章 {}".format(v, "OK" if v >= 1 else "REVIEW"))
        if report["2_惯用语命中率"].get("命中"):
            print("      命中:{}".format(", ".join(report["2_惯用语命中率"]["命中"][:6])))
    if report.get("3_立场显影溯源率", {}).get("value") is not None:
        v = report["3_立场显影溯源率"]["value"]
        print("  [立场显影溯源率] {0:%} {1}".format(v, "OK" if v >= 0.8 else "REVIEW"))


if __name__ == "__main__":
    main()