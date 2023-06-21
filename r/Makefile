SHELL=bash

all:

requirements:
	Rscript -e "install.packages(c('knitr', 'rmarkdown'))"

install:
	Rscript -e "install.packages('.', repos = NULL)"

build:
	mkdir -p ".local"
	cd ".local" && R CMD build ..

check: build
	cd ".local" && R CMD check --as-cran port4me_*.tar.gz

.local/port4me-overview.md:
	mkdir -p ".local"
	Rscript -e "rmarkdown::render('vignettes/port4me-overview.Rmd', rmarkdown::md_document(), output_dir = '.local')"

