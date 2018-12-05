all: move rmd2md

move:
		cp inst/vign/brranching_vignette.md vignettes;\
		cp -r inst/vign/figure/ vignettes/figure/

rmd2md:
		cd vignettes;\
		mv brranching_vignette.md brranching_vignette.Rmd
