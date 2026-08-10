#!/usr/bin/env python3
"""递增 pubspec.yaml 的版本号。

version 格式：<versionName>+<versionCode>，例如 1.1.0+2
  versionName（1.1.0）用户可见，显示在商店和「关于」里
  versionCode（2）  Play 内部用，**每次上传必须比上次大**，且永不回退

用法：
  python3 tool/bump_version.py            # 只 +1 versionCode（最常用：同版本重新打包）
  python3 tool/bump_version.py --patch    # 1.1.0 → 1.1.1，versionCode +1
  python3 tool/bump_version.py --minor    # 1.1.0 → 1.2.0，versionCode +1
  python3 tool/bump_version.py --major    # 1.1.0 → 2.0.0，versionCode +1
  python3 tool/bump_version.py --show     # 只打印当前版本，不修改
"""
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PUBSPEC = os.path.join(ROOT, "pubspec.yaml")
PATTERN = re.compile(r"^version:\s*(\d+)\.(\d+)\.(\d+)\+(\d+)\s*$", re.M)


def read():
    text = open(PUBSPEC).read()
    m = PATTERN.search(text)
    if not m:
        sys.exit("pubspec.yaml 里找不到形如 `version: 1.2.3+4` 的版本行")
    major, minor, patch, code = (int(g) for g in m.groups())
    return text, m, major, minor, patch, code


def main():
    args = set(sys.argv[1:])
    text, m, major, minor, patch, code = read()

    if "--show" in args:
        print(f"{major}.{minor}.{patch}+{code}")
        return

    if "--major" in args:
        major, minor, patch = major + 1, 0, 0
    elif "--minor" in args:
        minor, patch = minor + 1, 0
    elif "--patch" in args:
        patch += 1

    code += 1  # versionCode 任何情况下都 +1
    new = f"version: {major}.{minor}.{patch}+{code}"
    open(PUBSPEC, "w").write(text[: m.start()] + new + text[m.end():])
    print(f"{m.group(0).split(':')[1].strip()}  →  {major}.{minor}.{patch}+{code}")


if __name__ == "__main__":
    main()
