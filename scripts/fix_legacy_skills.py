# -*- coding: utf-8 -*-
import os, re

base = r'D:\第二职业\进行中\网文写作\提示词'

mapping = {
    'strengthen-chapter-opening': '通用-强化章节开头',
    'strengthen-chapter-opening-hook': '通用-强化章节开头',
    'strengthen-ending-hook': '通用-强化章末钩子',
    'strengthen-ending-hook-next-chapter': '通用-强化章末钩子',
    'rewrite-chapter-de-ai': '通用-去AI味重写',
    'design-part-volume-outline': '通用-设计分卷大纲',
    'design-total-outline': '通用-设计总大纲',
    'design-story-facet': '通用-设计故事面',
    'design-tech-setting': '通用-设计故事设定',
    'design-character-bible': '通用-设计人物传记',
    'design-unit-case-engine': '通用-设计事件案件引擎',
    'design-master-outline': '通用-设计总大纲',
    'design-urban-anomaly-positioning': '通用-设计题材定位框架',
    'evaluate-qidian-urban-weird-signing': '通用-平台签约评估框架',
    'evaluate-qidian-signing-probability': '通用-平台签约评估框架',
    'polish-author-note': '通用-润色作者有话说',
    'polish-author-note-reader-theater': '通用-润色作者有话说',
    'polish-chapter-body': '通用-正文润色',
    'polish-chapter-prose-urban-weird': '通用-正文润色',
    'review-chapter-body': '通用-审阅章节正文',
    'review-chapter-execution-urban-weird': '通用-审阅章节正文',
    'review-character-bible': '通用-审阅人物传记',
    'review-master-outline': '通用-审阅总大纲',
    'review-part-volume-outline': '通用-审阅分卷大纲',
    'review-tech-setting': '通用-审阅故事设定',
    'review-total-outline': '通用-审阅总大纲',
    'prepare-chapter-control-card': '通用-生成章节控制卡',
    'purify-multi-platform-source-draft': '通用-提纯多平台母稿',
    'refine-multi-platform-master-draft': '通用-提纯多平台母稿',
    'adapt-platform-fiction': '通用-多平台小说适配',
    'chapter-continuity-control': '通用-管理连续性冷热线',
    'manage-continuity-line-heat': '通用-管理连续性冷热线',
    'execute-microspace-horror-scene': '通用-执行微空间受限场景',
    'authenticity-and-de-ai-urban-weird': '通用-去AI味重写',
}

legacy_dirs = ['old都市悬疑', 'old异能志怪']
count = 0

for genre in legacy_dirs:
    skills_dir = os.path.join(base, genre, '.github', 'skills')
    if not os.path.isdir(skills_dir):
        print(f'[{genre}] No skills dir')
        continue
    folders = [f for f in os.listdir(skills_dir) if os.path.isdir(os.path.join(skills_dir, f))]
    print(f'[{genre}] {len(folders)} legacy skills')

    for fname in folders:
        md_path = os.path.join(skills_dir, fname, 'SKILL.md')
        if not os.path.isfile(md_path):
            continue

        generic = mapping.get(fname)
        if not generic:
            print(f'  ? {fname} (no mapping)')
            continue

        with open(md_path, 'r', encoding='utf-8') as f:
            c = f.read()
        orig = c

        has_section = '## 对应通用 Skill' in c

        if not has_section:
            section_content = '\r\n## 对应通用 Skill\r\n\r\n- `' + generic + '`'

            fm_match = re.search(r'\A---\r?\n(.*?)\r?\n---', c, re.DOTALL)
            if not fm_match:
                print(f'  ! {fname} (no fm)')
                continue
            after_fm = fm_match.end()
            after_fm_text = c[after_fm:]
            h1_match = re.search(r'^# .+', after_fm_text, re.MULTILINE)
            if not h1_match:
                print(f'  ! {fname} (no H1)')
                continue
            title_end = after_fm + h1_match.end()
            rest_after_title = c[title_end:]
            next_h2 = re.search(r'^## ', rest_after_title, re.MULTILINE)
            insert_pos = title_end + next_h2.start() if next_h2 else len(c)

            c = c[:insert_pos] + section_content + c[insert_pos:]

        c = c.replace('必须同时加载并使用', '必须优先强制加载')
        c = c.replace('必须加载并使用', '必须优先强制加载')
        c = c.replace('明确要求加载并使用', '明确要求优先强制加载并使用')

        if c != orig:
            with open(md_path, 'w', encoding='utf-8') as f:
                f.write(c)
            action = '+ added' if not has_section else '^ upgraded'
            print(f'  {action} {fname} -> {generic}')
            count += 1
        else:
            print(f'  . {fname} (unchanged)')

print(f'Legacy processed: {count} files')
