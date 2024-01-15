SHELL=bash

BROWSER=google-chrome

all:

requirements:
	Rscript -e "install.packages(c('knitr', 'rmarkdown'))"

install:
	Rscript -e "install.packages('.', repos = NULL)"

build:
	mkdir -p ".local"
	cd ".local" && R CMD build ..

check: shellcheck build
	cd ".local" && R CMD check --as-cran port4me_*.tar.gz
	cd ".local" && R CMD INSTALL port4me_*.tar.gz

shellcheck:
	(cd tests; shellcheck -x *.bats)

assert_bats:
	command -v "bats"
	echo "BATS_SUPPORT_HOME=$${BATS_SUPPORT_HOME:?}"
	echo "BATS_ASSERT_HOME=$${BATS_ASSERT_HOME:?}"

check-cli: assert_bats
	(cd tests/; PORT4ME_CLI_CALL="Rscript -e port4me::port4me --args" bats *.bats)

coverage-html:
	tf=$$(mktemp --suffix="-report.html"); \
	Rscript -e "c <- covr::package_coverage(quiet = FALSE); print(c); r <- covr::report(c, file='$${tf}'); utils::browseURL(r, browser = '$(BROWSER)')"

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
