brranching
==========



[![Project Status: Active - The project has reached a stable, usable state and is being actively developed.](http://www.repostatus.org/badges/latest/active.svg)](http://www.repostatus.org/#active)
[![Build Status](https://travis-ci.org/ropensci/brranching.svg?branch=master)](https://travis-ci.org/ropensci/brranching)
[![codecov.io](https://codecov.io/github/ropensci/brranching/coverage.svg?branch=master)](https://codecov.io/github/ropensci/brranching?branch=master)
[![cran checks](https://cranchecks.info/badges/worst/brranching)](https://cranchecks.info/pkgs/brranching)
[![rstudio mirror downloads](http://cranlogs.r-pkg.org/badges/brranching)](https://github.com/metacran/cranlogs.app)
[![cran version](https://www.r-pkg.org/badges/version/brranching)](https://cran.r-project.org/package=brranching)

## Description

Brranching is an interface to many different sources of phylogenetic data (currently only from Phylomatic (http://phylodiversity.net/phylomatic/), but more sources to come) that allows users to query for phylogenetic data using taxonomic names.  

For `brranching::phylomatic_names()` function you should get an NCBI Entrez API key. NCBI Entrez doesn't require that 
you use an API key, but you get higher rate limit with a key, from 3 to 10 requests per second, so do 
get one. Run `taxize::use_entrez()` or see 
<https://ncbiinsights.ncbi.nlm.nih.gov/2017/11/02/new-api-keys-for-the-e-utilities/>
for instructions.

## Installation

Stable CRAN version


```r
install.packages("brranching")
```

Or dev version


```r
install.packages("devtools")
devtools::install_github("ropensci/brranching")
```


```r
library("brranching")
```

## Phylomatic


```r
taxa <- c("Poa annua", "Phlox diffusa", "Helianthus annuus")
tree <- phylomatic(taxa=taxa, get = 'POST')
plot(tree, no.margin=TRUE)
```

![plot of chunk unnamed-chunk-5](tools/img/unnamed-chunk-5-1.png)

You can pass in up to about 5000 names. We can use `taxize` to get a random set of plant species names.


```r
library("taxize")
spp <- names_list("species", 200)
out <- phylomatic(taxa = spp, get = "POST")
plot(out, show.tip.label = FALSE)
```

![plot of chunk unnamed-chunk-6](tools/img/unnamed-chunk-6-1.png)

## Bladj


```r
library("phylocomr")
ages_df <- data.frame(
  a = c('malpighiales','eudicots','ericales_to_asterales','plantaginaceae',
        'malvids', 'poales'),
  b = c(81, 20, 56, 76, 47, 71)
)
phylo_file <- system.file("examples/phylo_bladj", package = "phylocomr")
phylo_str <- readLines(phylo_file)
x <- rbladj(tree = phylo_str, ages = ages_df)
library(ape)
plot(x)
```

![plot of chunk unnamed-chunk-7](tools/img/unnamed-chunk-7-1.png)

## Meta

* Please [report any issues or bugs](https://github.com/ropensci/brranching/issues).
* License: MIT
* Get citation information for `brranching` in R doing `citation(package = 'brranching')`
* Please note that this project is released with a [Contributor Code of Conduct][coc]
By participating in this project you agree to abide by its terms.

[![rofooter](https://ropensci.org/public_images/github_footer.png)](https://ropensci.org)

[coc]: https://github.com/ropensci/brranching/blob/master/CODE_OF_CONDUCT.md
