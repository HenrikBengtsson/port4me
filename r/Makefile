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

spelling:
	Rscript -e "spelling::spell_check_package()"
	Rscript -e "spelling::spell_check_files(c('NEWS.md', dir('vignettes', pattern='[.]Rmd$$', full.names=TRUE)), ignore=readLines('inst/WORDLIST', warn=FALSE))"

WIN_BUILDER = win-builder.r-project.org
win-builder-devel: .local/port4me_*.tar.gz
	curl -v -T "$?" ftp://anonymous@$(WIN_BUILDER)/R-devel/

win-builder-release: .local/port4me_*.tar.gz
	curl -v -T "$?" ftp://anonymous@$(WIN_BUILDER)/R-release/

win-builder: win-builder-devel win-builder-release
