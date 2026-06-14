TEXBIN ?= $(HOME)/.TinyTeX/bin/x86_64-linux
PDFLATEX ?= $(if $(wildcard $(TEXBIN)/pdflatex),$(TEXBIN)/pdflatex,pdflatex)
BIBTEX ?= $(if $(wildcard $(TEXBIN)/bibtex),$(TEXBIN)/bibtex,bibtex)

thesis:
	@$(PDFLATEX) $@
	@$(BIBTEX) $@
	@$(PDFLATEX) $@
	@$(PDFLATEX) $@
	@$(PDFLATEX) $@

clean:
	rm -rf *.pdf
	find . -type f \( -name "*.aux" -o -name "*.log" -o -name "*.lof" -o -name "*.lot" -o -name "*.out" -o -name "*.toc" -o -name "*.bbl" -o -name "*.blg" \) -exec rm {} \;
