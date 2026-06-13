#!/usr/bin/env python3
"""
gen_meta.py -- Markdown フロントマターから version/date/commit を読み取り、
PDF 用 LaTeX 定義ファイルまたは HTML 用 YAML メタデータを標準出力へ出力する。

使い方:
  python3 gen_meta.py <mdファイル> <lang: ja|en> <mode: tex|yaml>
"""
import sys
import re


def main():
    if len(sys.argv) != 4:
        sys.exit(f'Usage: {sys.argv[0]} <md_file> <ja|en> <tex|yaml>')

    md_file, lang, mode = sys.argv[1], sys.argv[2], sys.argv[3]

    with open(md_file, encoding='utf-8') as f:
        content = f.read()

    version_m = re.search(r'^version:\s*["\']?([\d.]+)', content, re.M)
    date_m    = re.search(r'^date:.*?(\d{4})',          content, re.M)
    commit_m  = re.search(r'^commit:\s*["\']?([^"\'\s]+)', content, re.M)

    if not version_m:
        sys.exit(f'Error: "version" field not found in {md_file}')
    if not date_m:
        sys.exit(f'Error: "date" field not found in {md_file}')
    if not commit_m:
        sys.exit(f'Error: "commit" field not found in {md_file}')

    version = version_m.group(1)
    year    = date_m.group(1)
    commit  = commit_m.group(1)

    if lang == 'ja':
        docversion = f'第 {version} 版 (commit id: {commit})'
    else:
        docversion = f'Version {version} (commit id: {commit})'

    if mode == 'tex':
        print(f'\\def\\TBCopyYear{{{year}}}')
        print(f'\\newcommand{{\\docversion}}{{{docversion}}}')
    elif mode == 'yaml':
        print(f'year: "{year}"')
        print(f'docversion: "{docversion}"')
    else:
        sys.exit(f'Error: unknown mode {mode!r} (expected tex or yaml)')


if __name__ == '__main__':
    main()
