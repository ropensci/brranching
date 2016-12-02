#' Use Phylomatic locally - ideal for large queries
#'
#' @export
#' @param taxa (character) Phylomatic format input of taxa names.
#' @param taxnames If \code{TRUE} (default), we get the family names for you
#' to attach to your species names to send to Phylomatic API. If \code{FALSE},
#' you have to provide the strings in the right format.
#' @param storedtree One of R20120829 (Phylomatic tree R20120829 for plants),
#'    smith2011 (Smith 2011, plants), binindaemonds2007 (Bininda-Emonds 2007,
#'    mammals), or zanne2014 (Zanne et al. 2014, plants). Default: R20120829
#' @param db (character) One of "ncbi", "itis", or "apg". Default: apg
#' @param verbose (logical) Print messages. Default: \code{TRUE}
#'
#' @return Newick formatted tree as \code{phylo} object or
#' nexml character string
#'
#' @details This function uses Phylomatic via Phylocom using the
#' \pkg{phylocom} package. The interface is slightly different: there's no
#' tree by URL avaialable, and some of the parameters are not included here.
#'
#' @examples \dontrun{
#' library('ape')
#'
#' # Input taxonomic names
#' taxa <- c("Poa annua", "Phlox diffusa", "Helianthus annuus")
#' (tree <- phylomatic_local2(taxa))
#' plot(collapse.singles(tree), no.margin=TRUE)
#'
#' taxa <- c("Poa annua", "Collomia grandiflora", "Lilium lankongense",
#' "Phlox diffusa", "Iteadaphne caudata", "Gagea sarmentosa",
#' "Helianthus annuus")
#' (tree <- phylomatic_local2(taxa))
#' plot(collapse.singles(tree), no.margin=TRUE)
#'
#' plot(collapse.singles(tree), no.margin=TRUE)
#'
#' library("taxize")
#' spp <- names_list("species", 1000)
#' length(spp)
#' (tree <- phylomatic_local2(spp))
#' }

phylomatic_local2 <- function(taxa = NULL, taxnames = TRUE, storedtree = "R20120829",
                             db = "apg", verbose = TRUE) {

  mssg(verbose, "preparing names...")
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

  if (tree %in% names(phylomatic_trees)) {
    tree <- phylomatic_trees[[tree]]
  }
  mssg(verbose, "processing with phylomatic...")
  out <- phylocom::ph_phylomatic(taxa = dat_, phylo = tree)

  if (grepl("No taxa in common|over 200kB", out)) {
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
