DATE      := $(shell git log -1 --format=%cd --date=format:"%B %-d, %Y")
COMMIT_ID := $(shell git log -1 --format=%h)
SED_SUBST := -e "s/%%__LAST_COMMIT_DATE__%%/$(DATE)/g" \
             -e "s/%%__LAST_COMMIT_ID__%%/$(COMMIT_ID)/g"

logo.pdf:
	rsvg-convert -f pdf -o logo.pdf ./images/logo.svg

pdf-ja: logo.pdf
	sed $(SED_SUBST) manual_ja.md > /tmp/manual_ja_build.md
	python3 gen_meta.py /tmp/manual_ja_build.md ja tex > manual_defs_ja.tex
	pandoc -f markdown -t pdf --pdf-engine=lualatex \
		-V documentclass=ltjsreport \
		-V classoption="12pt" \
		-V geometry="a4paper, top=30mm, bottom=30mm, inner=20mm, outer=20mm, headheight=14mm" \
		-V linestretch=1.2 \
		-V colorlinks=true \
		-V linkcolor=TBInternalLink \
		-V urlcolor=TBLink \
		-V citecolor=TBInternalLink \
		-H pandoc_template_ja.tex \
		-H manual_defs_ja.tex \
		--lua-filter=color.lua \
		-M lang=ja \
		--top-level-division=chapter \
		--toc \
		--toc-depth=3 \
		--number-sections \
		--highlight-style tango \
		-o manual_ja.pdf /tmp/manual_ja_build.md
	rm /tmp/manual_ja_build.md

pdf-en: logo.pdf
	sed $(SED_SUBST) manual_en.md > /tmp/manual_en_build.md
	python3 gen_meta.py /tmp/manual_en_build.md en tex > manual_defs_en.tex
	pandoc -f markdown -t pdf --pdf-engine=lualatex \
		-V documentclass=ltjsreport \
		-V classoption="12pt, english" \
		-V geometry="a4paper, top=30mm, bottom=30mm, inner=20mm, outer=20mm, headheight=14mm" \
		-V linestretch=1.2 \
		-V colorlinks=true \
		-V linkcolor=TBInternalLink \
		-V urlcolor=TBLink \
		-V citecolor=TBInternalLink \
		-H pandoc_template_en.tex \
		-H manual_defs_en.tex \
		--lua-filter=color.lua \
		--top-level-division=chapter \
		--toc \
		--toc-depth=3 \
		--number-sections \
		--highlight-style tango \
		-o manual_en.pdf /tmp/manual_en_build.md
	rm /tmp/manual_en_build.md

html-ja:
	sed $(SED_SUBST) manual_ja.md > /tmp/manual_ja_build.md
	python3 gen_meta.py /tmp/manual_ja_build.md ja yaml > manual_meta_ja.yaml
	pandoc -f markdown -t html \
		--template=pandoc_template.html \
		--metadata-file=manual_meta_ja.yaml \
		--lua-filter=color.lua \
		-M lang=ja \
		--toc \
		--toc-depth=3 \
		--number-sections \
		--highlight-style tango \
		-o manual_ja.html /tmp/manual_ja_build.md
	rm /tmp/manual_ja_build.md

html-en:
	sed $(SED_SUBST) manual_en.md > /tmp/manual_en_build.md
	python3 gen_meta.py /tmp/manual_en_build.md en yaml > manual_meta_en.yaml
	pandoc -f markdown -t html \
		--template=pandoc_template.html \
		--metadata-file=manual_meta_en.yaml \
		--lua-filter=color.lua \
		--toc \
		--toc-depth=3 \
		--number-sections \
		--highlight-style tango \
		-o manual_en.html /tmp/manual_en_build.md
	rm /tmp/manual_en_build.md
