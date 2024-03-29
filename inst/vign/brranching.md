<!--
%\VignetteEngine{knitr::knitr}
%\VignetteIndexEntry{brranching vignette}
%\VignetteEncoding{UTF-8}
-->

brranching - an interface to phylogenetic data
======



## Description

Brranching is an interface to many different sources of phylogenetic data (currently only from [Phylomatic](http://phylodiversity.net/phylomatic/), but more sources to come). It is used to query for phylogenetic data using taxonomic names and can be used to visualize the evolutionary history and relationships among individuals or groups of organisms. 

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

Query Phylomatic for a phylogenetic tree.


```r
taxa <- c("Poa annua", "Phlox diffusa", "Helianthus annuus")
tree <- phylomatic(taxa=taxa, get = 'POST')
plot(tree, no.margin=TRUE)
```

![plot of chunk unnamed-chunk-5](figure/unnamed-chunk-5-1.png)

You can pass in up to about 5000 names. We can use [`taxize`](https://github.com/ropensci/taxize/) to get a random set of plant species names.


```r
library("taxize")
spp <- names_list("species", 200)
out <- phylomatic(taxa = spp, get = "POST")
plot(out, show.tip.label = FALSE)
```

![plot of chunk unnamed-chunk-6](figure/unnamed-chunk-6-1.png)

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

![plot of chunk unnamed-chunk-7](figure/unnamed-chunk-7-1.png)
