check:
	cd tests/; \
	for ff in *.R; do \
	    echo "$$ff:"; \
	    Rscript --vanilla "$$ff" || exit 1; \
	done
