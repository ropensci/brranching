brranching 0.4.0
================

### NEW FEATURES

* in the `phylomatic_local()` function now using `phylocomr::ph_phylomatic`  instead of shelling out to Phylocom via `system`. A number of parameters are gone due to the change internally (#30) (#35)
* in the `rbladj()` function now using `phylocomr::ph_bladj` instead of shelling out to Phylocom via `system` (#30) (#35)
* added a package vignette (#31) (#34) thanks @fozy81
* added new dataset of four phylogenetic trees that can be used in `phylomatic_local()`, see `?phylomatic_trees`

### MINOR IMPROVEMENTS

* added docs to `phylomatic_names()` and the README on using NCBI Entrez API keys


brranching 0.3.0
================

### NEW FEATURES

* gains new function `bladj`  (#18)
* replaced `httr` with `crul` for http requests (#25)

### MINOR IMPROVEMENTS

* fix links to readme images (#29) (#26)
* `verbose` param in `phylomatic()` function changed to `mssgs`


brranching 0.2.0
================

### NEW FEATURES

* Added function `phylomatic_local()` to use Phylomatic locally. 
Phylomatic is a set of Awk scripts, which have to be downloaded 
by the user. After downloading, this function uses the local version 
of Phylomatic (Same as that that runs as a web service). This is 
advantageous especially when dealing with large queries. (#13)

### MINOR IMPROVEMENTS

* Fixed `clean` parameter in `phylomatic()` and `phylomatic_local()`
to expect a logical (`TRUE` or `FALSE`) instead of a "true" or "false". (#15)
* A related change to that above, changed reading newick strings to use 
`phytools::read.newick()` instead of `ape::read.tree()`, which handles
the result of `clean=FALSE` in `phylomatic()` and `phylomatic_local()` (#16)
* Documented that in the `storedtree` parameter of `phylomatic()` and 
`phylomatic_local()` the tree from Zanne et al. is also available by using
`storedtree="zanne2014"` (#19)


brranching 0.1.0
================

### NEW FEATURES

* Released to CRAN.
