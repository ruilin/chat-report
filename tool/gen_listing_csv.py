#!/usr/bin/env python3
"""把各语言的商店文案合成一个 CSV，用于 Play Console 的文案导入。

Play Console 可以上传一个结构化文件（CSV 或 Google 表格），
由它预先填好各语言的商品详情，检查后提交。Google 没有公布固定的列格式，
这里用一行一种语言、列名直白的写法。

文案仍然在 docs/store/<语言>/LISTING.md 里维护（那里有字数和注意事项的备注），
改完文案后重新跑一次本脚本：

    python3 tool/gen_listing_csv.py
    → docs/store/store_listings.csv
"""
import csv
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
STORE = os.path.join(ROOT, "docs/store")
OUT = os.path.join(STORE, "store_listings.csv")

# (docs/store 下的目录, Play Console 的语言代码, 语言名)
# 繁体中文在 Play 里分台湾和香港两个语言，文案相同
LANGS = [
    ("en", "en-US", "English (United States)"),
    ("zh", "zh-CN", "Chinese (Simplified)"),
    ("zh-Hant", "zh-TW", "Chinese (Traditional, Taiwan)"),
    ("zh-Hant", "zh-HK", "Chinese (Traditional, Hong Kong)"),
    ("es", "es-419", "Spanish (Latin America)"),
    ("pt", "pt-BR", "Portuguese (Brazil)"),
    ("fr", "fr-FR", "French (France)"),
    ("de", "de-DE", "German"),
    ("it", "it-IT", "Italian"),
    ("tr", "tr-TR", "Turkish"),
    ("ar", "ar", "Arabic"),
    ("hi", "hi-IN", "Hindi"),
    ("id", "id", "Indonesian"),
]
LIMITS = {"App name": 30, "Short description": 80, "Full description": 4000}


def read_listing(lang_dir):
    """LISTING.md 里依次有三个代码框：标题、简短说明、完整说明"""
    path = os.path.join(STORE, lang_dir, "LISTING.md")
    with open(path, encoding="utf-8") as f:
        blocks = re.findall(r"```\n(.*?)\n```", f.read(), re.S)
    if len(blocks) != 3:
        raise SystemExit(f"{path}: 应该有 3 个代码框，实际 {len(blocks)} 个")
    return dict(zip(LIMITS, blocks))


def main():
    rows, problems = [], []
    for lang_dir, code, name in LANGS:
        listing = read_listing(lang_dir)
        for field, limit in LIMITS.items():
            if len(listing[field]) > limit:
                problems.append(f"{code} {field}: {len(listing[field])} > {limit}")
        rows.append({"Language code": code, "Language": name, **listing})
    if problems:
        raise SystemExit("超出 Play 的字数上限：\n  " + "\n  ".join(problems))

    # 带 BOM：Excel 和 Google 表格才会按 UTF-8 打开，不然中文、阿拉伯文会乱码
    with open(OUT, "w", encoding="utf-8-sig", newline="") as f:
        writer = csv.DictWriter(
            f, fieldnames=["Language code", "Language", *LIMITS], quoting=csv.QUOTE_ALL)
        writer.writeheader()
        writer.writerows(rows)
    print(f"{os.path.relpath(OUT, ROOT)}：{len(rows)} 种语言")


if __name__ == "__main__":
    sys.exit(main())
