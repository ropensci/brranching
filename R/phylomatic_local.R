#' Use Phylomatic locally - ideal for large queries
#'
#' @export
#' @param taxa Phylomatic format input of taxa names.
#' @param taxnames If \code{TRUE} (default), we get the family names for you to attach
#' to your species names to send to Phylomatic API. If \code{FALSE}, you have to
#' provide the strings in the right format.
#' @param informat One of newick (default), nexml, or cdaordf. If using a stored tree,
#'    informat should always be newick.
#' @param method One of phylomatic (default) or convert
#' @param storedtree One of R20120829 (Phylomatic tree R20120829 for plants),
#'    smith2011 (Smith 2011, plants), or binindaemonds2007 (Bininda-Emonds 2007,
#'    mammals). Default: R20120829
#' @param treeuri URL for a phylogenetic tree in newick format.
#' @param taxaformat Only option is slashpath for now. Leave as is.
#' @param outformat One of newick, nexml, or fyt.
#' @param clean Return a clean tree or not. Default: \code{true}
#' @param db One of "ncbi", "itis", or "apg". Default: apg
#' @param verbose Print messages. Default: \code{TRUE}
#' @param ... curl options passed on to \code{\link[httr]{GET}} or \code{\link[httr]{POST}}
#'
#' @section Fetch Phylomatic code:
#' Download the code by doing \code{git clone https://github.com/camwebb/phylomatic-ws}
#' which will result in a folder \code{phylomatic-ws} (or download a zip file, and uncompress
#' it). Then give the path to that folder in the \code{path} parameter
#'
#' @return Newick formatted tree as \code{phylo} object or
#' nexml character string
#'
#' @examples \dontrun{
#' # Input taxonomic names
#' taxa <- c("Poa annua", "Phlox diffusa", "Helianthus annuus")
#' tree <- phylomatic_local(taxa, path = "~/github/play/phylomatic-ws")
#' plot(tree, no.margin=TRUE)
#'
#' taxa <- c("Poa annua", "Collomia grandiflora", "Lilium lankongense", "Phlox diffusa",
#' "Iteadaphne caudata", "Gagea sarmentosa", "Helianthus annuus")
#' tree <- phylomatic_local(taxa, path = "~/github/play/phylomatic-ws")
#'
#' library("taxize")
#' spp <- names_list("species", 6000)
#' (tree <- phylomatic_local(spp, path = "~/github/play/phylomatic-ws"))
#' }

phylomatic_local <- function(taxa = NULL, taxauri = NULL, taxnames = TRUE,
  informat = "newick", method = "phylomatic", storedtree = "R20120829", treeuri = NULL,
  taxaformat = "slashpath", outformat = "newick", clean = "true", db="apg",
  verbose=TRUE, outfile = "out.new", path = "phylomatic-ws", ...) {

  # check for awk, gawk, and awk files
  check_if("awk")
  check_if("gawk")
  check_pmws(path)
  comment_lines(path)

  if (is.null(taxauri)) {
    if (taxnames) {
      dat_ <- phylomatic_names(taxa, format = 'isubmit', db = db)
      checknas <- sapply(dat_, function(x) strsplit(x, "/")[[1]][1])
      checknas2 <- checknas[match("na", checknas)]
      if (is.numeric(checknas2)) {
        stop(sprintf("A family was not found for the following taxa:\n %s \n\n try setting taxnames=FALSE, and passing in a vector of strings, like \n%s",
                     paste(sapply(dat_, function(x) strsplit(x, "/")[[1]][3])[match("na", checknas)], collapse = ", "),
                     'phylomatic(taxa = c("asteraceae/taraxacum/taraxacum_officinale", "ericaceae/gaylussacia/gaylussacia_baccata", "ericaceae/vaccinium/vaccinium_pallidum"), taxnames=FALSE, parallel=FALSE)'
        ))
      }
    } else {
      dat_ <- taxa
    }

    if (length(dat_) > 1) {
      dat_ <- paste(dat_, collapse = "\n")
    }
  }

  # Only one of storedtree or treeuri
  if (!is.null(treeuri)) storedtree <- NULL

  args <- cpt(list(taxa = dat_, taxauri = taxauri, informat = informat, method = method,
                   storedtree = storedtree, treeuri = treeuri, taxaformat = taxaformat,
                   outformat = outformat, clean = clean))
  argstr <- paste0(paste(names(args), args, sep = "="), collapse = "&")

  # process
  origpath <- getwd()
  setwd(path)
  on.exit(setwd(origpath))
  system(sprintf("echo '%s' | ./pmws > %s", argstr, outfile))
  # read in output
  out <- readLines(outfile)[3]

  if (grepl("No taxa in common", out)) {
    stop(out, call. = FALSE)
  } else {
    # parse out missing taxa note
    if (grepl("\\[NOTE: ", out)) {
      taxa_na <- strmatch(out, "NOTE:.+")
      taxa_na2 <- strmatch(taxa_na, ":\\s[A-Za-z].+")
      taxa_na2 <- strsplit(taxa_na2, ",")[[1]][-length(strsplit(taxa_na2, ",")[[1]])]
      taxa_na2 <- gsub(":|\\s", "", taxa_na2)
      taxa_na2 <- sapply(taxa_na2, function(x) strsplit(x, "/")[[1]][[3]], USE.NAMES = FALSE)
      taxa_na2 <- traits_capwords(gsub("_", " ", taxa_na2), onlyfirst = TRUE)

      mssg(verbose, taxa_na)
      out <- gsub("\\[NOTE:.+", ";\n", out)
    } else {
      taxa_na2 <- NULL
    }

    outformat <- match.arg(outformat, choices = c("nexml",'newick'))
    switch(outformat,
           nexml = structure(out, class = "phylomatic", missing = taxa_na2),
           newick = structure(getnewick(out), class = c("phylo", "phylomatic"), missing = taxa_na2))
  }
}

check_if <- function(x) {
  if (Sys.which(x) == "") stop(sys.call()[-1], " is missing, install it first", call. = FALSE)
}

check_pmws <- function(path) {
  if (file.exists(path)) {
    files <- list.files(path, recursive = TRUE)
    if (!all(phy_files %in% files)) {
      stop("code note available, see 'Fetch Phylomatic code' section", call. = FALSE)
    }
  } else {
    stop("code note available, see 'Fetch Phylomatic code' section", call. = FALSE)
  }
}

comment_lines <- function(x) {
  paths <- list.files(x, full.names = TRUE, recursive = TRUE)
  # phylomatic.aw
  pawk <- grep("phylomatic.awk", paths, value = TRUE)
  pawk_orig <- readLines(pawk)
  val <- grep("ntaxatrees > 5000", pawk_orig)
  if (length(val) != 0) {
    cat(pawk_orig[-grep("ntaxatrees > 5000", pawk_orig)], file = pawk, sep = "\n")
  }
  # pnws
  pmws <- grep("pmws", paths, value = TRUE)
  pmws_orig <- readLines(pmws)
  val <- grep("length\\(tmpquery\\[2\\]\\) > 200000", pmws_orig)
  if (length(val) != 0) {
    cat(pmws_orig[-c(val, val + 1)], file = pmws, sep = "\n")
  }
}

phy_files <- c("lib/cdao2fyt.awk", "lib/fyt2new.awk", "lib/fyt2nexml.awk", "lib/new2fyt.awk",
               "lib/nexml2fyt.awk", "lib/phylomatic.awk", "lib/readfyt.awk",
               "lib/utils.awk", "pmws")