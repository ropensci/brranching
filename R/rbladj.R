#' Run Phylocom's bladj from R
#'
#' @export
#' @param tree (phylo/character) If `NULL`, it is expected that you 
#' already have a phylo file with your newick tree in your directory 
#' with your phylocom executable 
#' @param ages (data.frame) If `NULL`, it is expected that you already 
#' have an ages file with your node names and ages in your directory with 
#' your Phylocom executable
#' @param path (character) Path to the folder with at least the Phylocom 
#' executable
#' @param fixroot (logical) If `TRUE` root name is changed to the oldest root 
#' in your ages file. If `FALSE` (default),
#' @details Download Phylocom http://phylodiversity.net/phylocom/phylocom-4.2.zip
#' @examples \dontrun{
#' library("taxize")
#' taxa <- names_list("species", 15)
#' tree <- phylomatic(taxa=taxa, get = 'POST')
#'
#' path <- "~/Mac/Courses_Rice/EcolJClub563/Fall10/phylometa_stuff/R_tutorial/bladjing/"
#' (tree2 <- rbladj(tree, path = path, fixroot = TRUE))
#' plot(tree)
#' plot(tree2)
#' }
rbladj <- function(tree=NULL, ages=NULL, path=NULL, fixroot=FALSE) {
  path <- path.expand(path)
  check_phylocom(path)
  orig_path <- getwd()
  on.exit(setwd(orig_path))

  #phylo
  if (!is.null(tree)) {
    if (!class(tree)[1] %in% c('phylo', 'character')) {
      sf("'tree' must be one of class 'phylo' or 'character'")
    }
    if (inherits(tree, "character")) {
      tree <- phytools::read.newick(file=paste(path,"phylo",sep=""))
    }
    ape::write.tree(tree, file = file.path(path, "phylo"))
  }

  #ages
  if (is.null(ages)) {
    tmp <- tryCatch(utils::read.table(file.path(path, "ages")), error = function(e) e)
    if (inherits(tmp, "error")){
      sf("You must provide an ages data.frame or a path to the ages file")
    }
  } else {
    if (inherits(ages, "data.frame")) {
      utils::write.table(ages, file = file.path(path, "ages"),
                         sep = "\t", col.names = FALSE,
                         row.names = FALSE, quote = FALSE)
    } else {
      sf("'ages' must be a path to a file or a data.frame. See ?rbladj")
    }
  }

  # check if root node in phylogeny is in the ages file
  if (is.null(tree)) {
    tree <- phytools::read.newick(file = file.path(path, "phylo"))
  }
  if (is.null(ages)) {
    ages <- stats::setNames(utils::read.table(file.path(path, "ages")), c("names","ages"))
  }
  rootnode <- as.character(tree$node.label[1])
  if (!rootnode %in% as.character(ages[,1])) {
    if (fixroot) {
      ages_sorted <- sortDF(ages, "ages")
      newroot <- as.character(ages_sorted[nrow(ages_sorted),1])
      tree <- ape::read.tree(text=sub(rootnode, newroot, ape::write.tree(tree)))
      ape::write.tree(tree, file = file.path(path, "phylo"))
    } else {
      sf("Your root node must be in your ages file - names must match exactly")
    }
  }

  #bladj
  if (.Platform$OS.type != "unix") {
    setwd(path)
    shell("phylocom bladj > phyloout.txt")
  } else {
    setwd(path)
    system("./phylocom bladj > phyloout.txt")
  }

  #read tree back in
  tr <- tryCatch(phytools::read.newick(file.path(path, "phyloout.txt")),
                 error = function(e) e)
  if (inherits(tr, "error")) sf("tree read error")
  return( tr )
}

check_phylocom <- function(x) {
  if (!file.exists(file.path(x, "phylocom"))) {
    sf("phylocom not found - make sure your path is correct")
  }
}

sf <- function(x) stop(x, call. = FALSE)

sortDF <- function(data, vars = names(data)) {
  if (length(vars) == 0 || is.null(vars)) return(data)
  data[do.call("order", data[, vars, drop = FALSE]), , drop = FALSE]
}
