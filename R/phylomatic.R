#' Query Phylomatic for a phylogenetic tree.
#'
#' @export
#' @param taxa Phylomatic format input of taxa names.
#' @param taxnames If \code{TRUE} (default), we get the family names for you to attach
#' to your species names to send to Phylomatic API. If \code{FALSE}, you have to
#' provide the strings in the right format.
#' @param get 'GET' (default) or 'POST' format for submission to the website.
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
#'
#' @details Use the web interface at \url{http://phylodiversity.net/phylomatic/}
#'
#' @return Newick formatted tree as \code{phylo} object or
#' nexml character string
#'
#' @examples \dontrun{
#' # Input taxonomic names
#' taxa <- c("Poa annua", "Phlox diffusa", "Helianthus annuus")
#' tree <- phylomatic(taxa=taxa, get = 'POST')
#' plot(tree, no.margin=TRUE)
#'
#' # Genus names
#' taxa <- c("Poa", "Phlox", "Helianthus")
#' tree <- phylomatic(taxa=taxa, storedtree='R20120829', get='POST')
#' plot(tree, no.margin=TRUE)
#'
#' # Lots of names
#' taxa <- c("Poa annua", "Collomia grandiflora", "Lilium lankongense", "Phlox diffusa",
#' "Iteadaphne caudata", "Gagea sarmentosa", "Helianthus annuus")
#' tree <- phylomatic(taxa=taxa, get = 'POST')
#' plot(tree, no.margin=TRUE)
#'
#' # Output NeXML format
#' taxa <- c("Gonocarpus leptothecus", "Gonocarpus leptothecus", "Lilium lankongense")
#' out <- phylomatic(taxa=taxa, get = 'POST', outformat = "nexml")
#' cat(out)
#'
#' # Lots of names, note that when you have enough names (number depends on length of individual
#' # names, so there's no per se rule), you will get an error when using \code{get='GET'},
#' # when that happens use \code{get='POST'}
#' library("taxize")
#' spp <- names_list("species", 200)
#' # phylomatic(taxa = spp, get = "GET")
#' (out <- phylomatic(taxa = spp, get = "POST"))
#' plot(out)
#'
#' # Pass in a tree from a URL on the web
#'
#' spp <- c("Abies_nordmanniana", "Abies_bornmuelleriana", "Abies_cilicica", "Abies_cephalonica",
#' "Abies_numidica", "Abies_pinsapo", "Abies_alba")
#' url <- "http://datadryad.org/bitstream/handle/10255/dryad.8791/final_tree.tre?sequence=1"
#' phylomatic(taxa=spp, treeuri=url)
#' }

phylomatic <- function(taxa, taxnames = TRUE, get = 'GET',
  informat = "newick", method = "phylomatic", storedtree = "R20120829", treeuri = NULL,
  taxaformat = "slashpath", outformat = "newick", clean = "true", db="apg", verbose=TRUE) {

  url = "http://phylodiversity.net/phylomatic/pmws"

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

  # Only one of storedtree or treeuri
  if (!is.null(treeuri)) storedtree <- NULL

  args <- cpt(list(taxa = dat_, informat = informat, method = method,
                       storedtree = storedtree, treeuri = treeuri, taxaformat = taxaformat,
                       outformat = outformat, clean = clean))

  if (get == 'POST') {
    tt <- POST(url, body = args, encode = 'form')
    out <- content(tt, as = "text", encoding = "UTF-8")
  } else if (get == 'GET') {
    tt <- GET(url, query = args)
    if (tt$status_code == 414) {
      stop("(414) Request-URI Too Long - Use get='POST' in your function call", call. = FALSE)
    } else {
      stop_for_status(tt)
    }
    out <- content(tt, as = "text", encoding = "UTF-8")
  } else {
    stop("get must be one of 'POST' or 'GET'", call. = FALSE)
  }

  if (grepl("No taxa in common", out)) {
    stop(out)
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
    getnewick <- function(x) {
      tree <- gsub("\n", "", x[[1]])
      read.tree(text = colldouble(tree))
    }

    switch(outformat,
           nexml = structure(out, class = "phylomatic", missing = taxa_na2),
           newick = structure(getnewick(out), class = c("phylo", "phylomatic"), missing = taxa_na2))

    # res <- switch(outformat,
    #        nexml = out,
    #        newick = getnewick(out))
    # structure(res, class = c("phylo", "phylomatic"), missing = taxa_na2)
  }
}

collapse_double_root <- function(y) {
  temp <- strsplit(y, ")")[[1]]
  double <- c(length(temp) - 1, length(temp))
  tempsplit <- temp[double]
  tempsplit_1 <- strsplit(tempsplit[1], ":")[[1]][2]
  tempsplit_2 <- strsplit(tempsplit[2], ":")[[1]]
  rootlength <- as.numeric(tempsplit_1) +
    as.numeric(strsplit(tempsplit_2[2], ";")[[1]][1])
  newx <- paste(")", tempsplit_2[1], ":", rootlength, ";", sep = "")
  newpre <- gsub("[(]", "", temp[1])
  allelse <- temp[-1]
  allelse <- allelse[setdiff(1:length(allelse), double - 1)]
  allelse <- paste(")", allelse, sep = "")
  paste(newpre, paste(allelse, collapse = ""), newx, sep = "")
}

colldouble <- function(z) {
  if ( class( try( read.tree(text = z), silent = T ) ) %in% 'try-error' ) {
    treephylo <- collapse_double_root(z)
  } else {
    treephylo <- z
  }
  return(treephylo)
}
