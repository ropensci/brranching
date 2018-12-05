#' Hierarchical Tree Generator
#'
#' Generates a phylogenetic tree from a taxon down to a chosen lower taxon.
#' @param taxon The higher taxon from which the tree will start.
#' @param downto The lowest level of taxonomy wanted. Must be included in the argument taxon.
#' @param key API key.
#' @import ape
#' @import brranching
#' @import phytools
#' @import taxize
#' @import xml2
#' @export
downto.tree<- function(taxon, downto, key=NULL){

  ##Query liste de taxon
  taxon_downto<-col_downstream(name=taxon, downto=downto)
  ##Extraire le vector des noms de taxons de la matrice
  taxon_list<-taxon_downto[[taxon]]
  #définir le vecteur comme taxon de reference
  taxa<-taxon_list$childtaxa_name

  find.tree<-function(x){
    #Obtenir le id de l'espece
    id.sp<-function(x){
      return(as.matrix(get_eolid(sciname = x, verbose = T,rows = 1,key = key)))
    }

    #trouver sa classification

    hier.sp<-classification(id.sp(x), db="eol") #hiérarchie espece
    class.query<-hier.sp[[id.sp(x)]] #isoler le terme de la classe

    #tree.select
    tree.select<-function(x){
      if ("Mammalia" %in% class.query$name) {
        return("binindaemonds2007")
      }
      else if ("Euphyllophyta" %in% class.query$name) {
        return("zanne2014")
      }
      else {
        stop("There is no stored tree for your taxon")
      }
    }
    tree.select(x)
  }


  #creer l'arbre
  tree <- phylomatic(taxa=taxa, storedtree =find.tree(sample(taxa, size=1)), get='POST', clean = T, db="itis")
  #representer l'arbre graphiquement
  plot(tree, no.margin=TRUE)

}
