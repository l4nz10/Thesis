#!/bin/bash
cat contents/other/references.bib | grep -v @comment | \
	sed 's/url = {\([^}]*\)}/url = {\1}, §  note = {Online: \\url{\1}}/g' | \
	tr '§' '\n' > contents/other/references_url.bib

pdflatex thesis.tex
makeglossaries thesis
bibtex thesis
pdflatex thesis.tex
pdflatex thesis.tex
pdflatex thesis.tex

REMOVE_USELESS_FILES=1
if [ $REMOVE_USELESS_FILES -gt 0 ]; then
	rm thesis.aux &>/dev/null
	rm thesis.lof &>/dev/null
	rm thesis.log &>/dev/null
	rm thesis.lot &>/dev/null
	rm thesis.out &>/dev/null
	rm thesis.toc &>/dev/null
	rm thesis.acn &>/dev/null
	rm thesis.glo &>/dev/null
	rm thesis.ist &>/dev/null
	rm thesis.acr &>/dev/null
	rm thesis.alg &>/dev/null
	rm thesis.glg &>/dev/null
	rm thesis.gls &>/dev/null
	rm thesis.bbl &>/dev/null
	rm thesis.blg &>/dev/null
	rm contents/other/references.bib.bak &>/dev/null
	rm contents/other/references_url.bib &>/dev/null
fi
#
clear; echo; echo;
#
./thesis.stat.sh
#
echo; echo;
