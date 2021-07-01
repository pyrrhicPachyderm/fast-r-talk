SHELL := /bin/bash
LATEXMK_FLAGS = --pdf --cd
RM := rm -f

slidedoc := slides
notedoc := notes
content_rnw_files := presentation.rnw
supporting_rnw_files := theme.rnw

all: $(slidedoc).pdf $(notedoc).pdf
.PHONY: all

%-dedented.rnw: dedent-noweb %.rnw
	./$< <$(word 2,$^) >$@

content_rnw_files_dedented := $(content_rnw_files:%.rnw=%-dedented.rnw)
supporting_rnw_files_dedented := $(supporting_rnw_files:%.rnw=%-dedented.rnw)

%.tex: %-dedented.rnw $(content_rnw_files_dedented) $(supporting_rnw_files_dedented)
	R -e 'library(knitr);knit("$<","$@")'
%.pdf: %.tex
	latexmk $(LATEXMK_FLAGS) --jobname="$(basename $@)" $<

clean:
	@(\
		shopt -s globstar;\
		$(RM) **/*.aux **/*.log **/*.fls **/*.fdb_latexmk;\
		$(RM) **/*.out **/*.nav **/*.snm **/*.toc **/*.vrb;\
		$(RM) **/*-dedented.rnw;\
		$(RM) **/*.tex;\
	)
	@$(RM) $(slidedoc).pdf $(notedoc).pdf
.PHONY: clean

spellcheck: $(content_rnw_files)
	@for file in $^; do \
		aspell check --per-conf=./aspell.conf "$$file" ;\
	done
.PHONY: spellcheck

#Never remove secondary files; .SECONDARY with no dependencies.
.SECONDARY:
