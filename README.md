branching
=======



R client to fetch phylogenies from many places

To be included, with the associated function prefix:

* [Phylomatic](http://phylodiversity.net/phylomatic/) - `phylomatic_`
* ...

## Installation


```r
install.packages("devtools")
devtools::install_github("sckott/branching")
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
plot(out)
```

![plot of chunk unnamed-chunk-5](inst/img/unnamed-chunk-5-1.png) 
