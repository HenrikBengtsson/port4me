SHELL=bash

all:

requirements:
	Rscript -e "install.packages(c('knitr', 'rmarkdown'))"

install:
	Rscript -e "install.packages('.', repos = NULL)"

build:
	mkdir -p ".local"
	cd ".local" && R CMD build ..

check:
	cd ".local" && R CMD check --as-cran port4me_*.tar.gz
	cd ".local" && R CMD INSTALL port4me_*.tar.gz

check-cli:
	module load CBI bats-core bats-assert bats-file; \
	(cd tests/; bats *.bats)

incl/OVERVIEW.md: vignettes/port4me-overview.Rmd
	Rscript -e "rmarkdown::render('vignettes/port4me-overview.Rmd', rmarkdown::md_document(), output_dir = '$(@D)', output_file = '$(@F)')"

README.md: incl/README.md.rsp incl/OVERVIEW.md
	Rscript -e "R.rsp::rfile('$<', postprocess=FALSE)"
