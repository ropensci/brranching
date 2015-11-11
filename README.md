brranching
==========




[![Build Status](https://travis-ci.org/ropensci/brranching.svg?branch=master)](https://travis-ci.org/ropensci/brranching)
[![codecov.io](https://codecov.io/github/ropensci/brranching/coverage.svg?branch=master)](https://codecov.io/github/ropensci/brranching?branch=master)
[![rstudio mirror downloads](http://cranlogs.r-pkg.org/badges/brranching)](https://github.com/metacran/cranlogs.app)

R client to fetch phylogenies from many places

To be included, with the associated function prefix:

* [Phylomatic](http://phylodiversity.net/phylomatic/) - `phylomatic`
* more to come ...

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

![plot of chunk unnamed-chunk-5](inst/img/unnamed-chunk-5-1.png) 

You can pass in up to about 5000 names. We can use `taxize` to get a random set of plant species names.


```r
library("taxize")
spp <- names_list("species", 200)
out <- phylomatic(taxa = spp, get = "POST")
plot(out, show.tip.label = FALSE)
```

![plot of chunk unnamed-chunk-6](inst/img/unnamed-chunk-6-1.png) 

## Meta

* Please [report any issues or bugs](https://github.com/ropensci/brranching/issues).
* License: MIT
* Get citation information for `brranching` in R doing `citation(package = 'brranching')`
* Please note that this project is released with a [Contributor Code of Conduct](CONDUCT.md). By participating in this project you agree to abide by its terms.

[![rofooter](http://ropensci.org/public_images/github_footer.png)](http://ropensci.org)
