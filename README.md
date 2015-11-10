branching
=======




[![Build Status](https://travis-ci.org/ropensci/branching.svg?branch=master)](https://travis-ci.org/ropensci/branching)

R client to fetch phylogenies from many places

To be included, with the associated function prefix:

* [Phylomatic](http://phylodiversity.net/phylomatic/) - `phylomatic`
* xxx

## Installation


```r
install.packages("devtools")
devtools::install_github("ropensci/branching")
```


```r
library("branching")
```

## Phylomatic


```r
taxa <- c("Poa annua", "Phlox diffusa", "Helianthus annuus")
tree <- phylomatic(taxa=taxa, get = 'POST')
plot(tree, no.margin=TRUE)
```

![plot of chunk unnamed-chunk-4](inst/img/unnamed-chunk-4-1.png) 

You can pass in up to about 5000 names. We can use `taxize` to get a random set of plant species names. 


```r
library("taxize")
spp <- names_list("species", 200)
out <- phylomatic(taxa = spp, get = "POST")
plot(out, show.tip.label = FALSE)
```

![plot of chunk unnamed-chunk-5](inst/img/unnamed-chunk-5-1.png) 

## Meta

* Please [report any issues or bugs](https://github.com/ropensci/branching/issues).
* License: MIT
* Get citation information for `branching` in R doing `citation(package = 'branching')`
* Please note that this project is released with a [Contributor Code of Conduct](CONDUCT.md). By participating in this project you agree to abide by its terms.

[![rofooter](http://ropensci.org/public_images/github_footer.png)](http://ropensci.org)
