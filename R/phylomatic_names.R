#' Phylomatic names
#'
#' @description Get family names to make Phylomatic input object, and
#' output input string to Phylomatic for use in the function phylomatic
#'
#' @export
#' @param taxa quoted tsn number (taxonomic serial number)
#' @param format output format, isubmit (you can paste in to the Phylomatic
#'     website), or 'rsubmit' to use in fxn phylomatic_tree
#' @param db One of "ncbi", "itis", or "apg". if you use "apg", no HTTP 
#' requests are made (no internet connection needed), whereas if you use 
#' "ncbi" or "itis" you do need an internet connection. IMPORTANT: 
#' see **Authentication** below if using "ncbi".
#' @param ... curl options passed on to [taxize::tax_name()]
#' @return string (e.g., "pinaceae/pinus/pinus_contorta"), in Phylomatic 
#' submission format
#' @section Authentication:
#' NCBI Entrez doesn't require that you use an API key, but you get
#' higher rate limit with a key, from 3 to 10 requests per second, so do 
#' get one. Run [taxize::use_entrez()] or see 
#' https://ncbiinsights.ncbi.nlm.nih.gov/2017/11/02/new-api-keys-for-the-e-utilities/
#' for instructions.
#' 
#' NCBI API key handling logic is done inside of the `taxize` package, used 
#' inside this function.
#' 
#' Save your API key with the name `ENTREZ_KEY` as an R option in your 
#' `.Rprofile` file, or as environment variables in either your `.Renviron` 
#' file or `.bash_profile` file, or `.zshrc` file (if you use oh-my-zsh) or
#' similar. See [Startup] for help on R options and environment
#' variables. You cannot pass in your API key in this function.
#'
#' Remember to restart your R session (and to start a new shell window/tab
#' if you're using the shell) to take advantage of the new R options
#' or environment variables.
#'
#' We strongly recommend using environment variables over R options.
#' 
#' Note that if you don't have an ENTREZ_KEY set, you'll get a message
#' about it, but only once during each function call. That is, there
#' can be of these messages per R session, across function calls.
#' @examples \dontrun{
#' mynames <- c("Poa annua", "Salix goodingii", "Helianthus annuus")
#' phylomatic_names(taxa = mynames, format='rsubmit')
#' phylomatic_names(mynames, format='rsubmit', db="apg")
#' phylomatic_names(mynames, format='isubmit', db="ncbi")
#' phylomatic_names(mynames, format='isubmit', db="apg")
#' }

phylomatic_names <- function(taxa, format='isubmit', db="ncbi", ...) {
  format <- match.arg(format, c('isubmit', 'rsubmit'))
  db <- match.arg(db, c('ncbi', 'itis', 'apg'))
  ck <- conditionz::ConditionKeeper$new(times = 1)
  on.exit(ck$purge())

  foo <- function(nnn) {
    # split up strings if a species name
    nnn <- iconv(nnn, from = "ISO_8859-2", to = "UTF-8")
    taxa2 <- strsplit(gsub("_"," ",nnn), "\\s")[[1]]
    taxa_genus <- traits_capwords(taxa2[[1]], onlyfirst = TRUE)

    if (db %in% c("ncbi", "itis")) {
      family <- ck$handle_conditions(
        taxize::tax_name(
          query = taxa_genus, get = "family", db = db, messages = FALSE, 
          ...)$family)
    } else {
      tplfamily <- tpl[ match(taxa_genus, tpl$genus), "family" ]
      dd <- taxize::apg_families[ match(tplfamily, taxize::apg_families$this), ]
      if (nchar(as.character(dd$that), keepNA = FALSE) == 0) {
        family <- dd$this
      } else {
        family <- dd$that
      }
    }
    stringg <- c(family, strsplit(nnn, " ")[[1]])
    stringg <- tolower(as.character(stringg))
    if (format == 'isubmit') {
      paste(stringg[[1]], "/", stringg[2], "/", tolower(sub(" ", "_", nnn)), sep = '')
    } else {
      if (format == 'rsubmit') {
        paste(stringg[[1]], "%2F", stringg[2], "%2F", tolower(sub(" ", "_", nnn)), sep = '')
      }
    }
  }
  sapply(taxa, foo, USE.NAMES = FALSE)
}
