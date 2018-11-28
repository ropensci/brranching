#' Run Phylocom's bladj from R
#'
#' @export
#' @param tree (character/phylo) One of: phylogeny as a newick string (will be
#' written to a temp file) - OR path to file with a newick
#' string - OR a an \pkg{ape} `phylo` object. required.
#' @param ages (data.frame/character) ages data.frame, or path to an ages
#' file. required.
#' @details uses [phylocomr::ph_bladj()] under the hood
#' @return Newick formatted tree as `phylo` object
#' @examples \dontrun{
#' library("phylocomr")
#'
#' # make an ages data.frame
#' ages_df <- data.frame(
#'   a = c('malpighiales','eudicots','ericales_to_asterales','plantaginaceae',
#'         'malvids', 'poales'),
#'   b = c(81, 20, 56, 76, 47, 71)
#' )
#' 
#' # read phylogeny file as a string
#' phylo_file <- system.file("examples/phylo_bladj", package = "phylocomr")
#' phylo_str <- readLines(phylo_file)
#' 
#' # Run Bladj, returns phylo object
#' (x <- rbladj(tree = phylo_str, ages = ages_df))
#' 
#' # load ape and plot tree
#' library(ape)
#' plot(x)
#' }
rbladj <- function(tree, ages) {
  res <- phylocomr::ph_bladj(ages, tree)
  ape::read.tree(text = res)
}
