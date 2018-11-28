#' Use Phylomatic locally - ideal for large queries
#'
#' @export
#' @param taxa (character) Phylomatic format input of taxa names.
#' @param taxnames If `TRUE` (default), we get the family names for you
#' to attach to your species names to send to Phylomatic API. If `FALSE`,
#' you have to provide the strings in the right format. See Details.
#' @param storedtree One of R20120829 (Phylomatic tree R20120829 for plants),
#' smith2011 (Smith 2011, plants), binindaemonds2007 (Bininda-Emonds 2007,
#' mammals), or zanne2014 (Zanne et al. 2014, plants). Default: R20120829
#' @param db (character) One of "ncbi", "itis", or "apg". Default: apg
#' @param lowercase	(logical) Convert all chars in taxa file to lowercase.
#' Default: `FALSE`
#' @param nodes (logical) label all nodes with default names.
#' Default: `FALSE`
#' @param verbose (logical) Print messages. Default: `TRUE`
#'
#' @return Newick formatted tree as `phylo` object
#'
#' @details This function uses Phylomatic via Phylocom using the
#' \pkg{phylocomr} package. The interface is slightly different from 
#' [phylomatic()]: there's no tree by URL available, and some of the 
#' parameters are not included here.
#'
#' If you set `taxnames = FALSE`, you need to pass in a character
#' vector, with each element like this example:
#' `"asteraceae/taraxacum/taraxacum_officinale"`, of the form
#' `"family/genus/genus_specfic epithet"`
#'
#' @examples \dontrun{
#' library('ape')
#'
#' # Input taxonomic names
#' taxa <- c("Poa annua", "Phlox diffusa", "Helianthus annuus")
#' (tree <- phylomatic_local(taxa))
#' plot(collapse.singles(tree), no.margin=TRUE)
#'
#' taxa <- c("Poa annua", "Collomia grandiflora", "Lilium lankongense",
#' "Phlox diffusa", "Iteadaphne caudata", "Gagea sarmentosa",
#' "Helianthus annuus")
#' (tree <- phylomatic_local(taxa))
#' plot(collapse.singles(tree), no.margin=TRUE)
#'
#' library("taxize")
#' spp <- names_list("species", 500)
#' length(spp)
#' (tree <- phylomatic_local(spp))
#' }

phylomatic_local <- function(taxa = NULL, taxnames = TRUE,
  storedtree = "R20120829", db = "apg", lowercase = FALSE, nodes = FALSE,
  verbose = TRUE) {

  mssg(verbose, "preparing names...")
  if (taxnames) {
    dat_ <- phylomatic_names(taxa, format = 'isubmit', db = db)
  } else {
    dat_ <- taxa
  }

  if (storedtree %in% names(phylomatic_trees)) {
    tree <- phylomatic_trees[[storedtree]]
  }
  mssg(verbose, "processing with phylomatic...")
  out <- phylocomr::ph_phylomatic(taxa = dat_, phylo = tree,
                                  lowercase = lowercase, nodes = nodes)
  out <- iconv(out, from = "ISO_8859-2", to = "UTF-8")

  if (suppressWarnings(grepl("No taxa in common|over 200kB", out))) {
    stop(out, call. = FALSE)
  } else {
    # parse out missing taxa note
    if (suppressWarnings(grepl("\\[NOTE: ", out))) {
      taxa_na <- strmatch(out, "NOTE:.+")
      taxa_na2 <- strmatch(taxa_na, ":\\s[A-Za-z].+")
      taxa_na2 <-
        strsplit(taxa_na2, ",")[[1]][-length(strsplit(taxa_na2, ",")[[1]])]
      taxa_na2 <- gsub(":|\\s", "", taxa_na2)
      taxa_na2 <- sapply(taxa_na2, function(x) strsplit(x, "/")[[1]][[3]],
                         USE.NAMES = FALSE)
      taxa_na2 <- traits_capwords(gsub("_", " ", taxa_na2), onlyfirst = TRUE)

      mssg(verbose, get_note(taxa_na))
      out <- gsub("\\[NOTE:.+", ";\n", out)
    } else {
      taxa_na2 <- NULL
    }

    structure(phytools::read.newick(text = out),
              class = c("phylo", "phylomatic"),
              missing = taxa_na2)
  }
}

get_note <- function(x) {
  tmp <- substring(x, 1, 300)
  if (nchar(x) > nchar(tmp)) paste0(tmp, " ...") else tmp
}
