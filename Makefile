RSCRIPT = Rscript --no-init-file

all: move rmd2md

move:
		cp inst/vign/brranching.md vignettes;\
		cp -r inst/vign/figure/ vignettes/figure/

rmd2md:
		cd vignettes;\
		mv brranching.md brranching.Rmd

install: doc build
	R CMD INSTALL . && rm *.tar.gz

build:
	R CMD build .

doc:
	${RSCRIPT} -e "devtools::document()"

eg:
	${RSCRIPT} -e "devtools::run_examples()"

