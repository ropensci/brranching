## ----setup, include=FALSE------------------------------------------------
knitr::opts_chunk$set(echo = TRUE)

## ----include=FALSE-------------------------------------------------------
library(aptg)


## ----taxa.tree, message=FALSE--------------------------------------------
taxa.tree(c("Canis lupus", "Canis latrans", "Acer saccharum", "Castor canadensis", "Alces alces", "Acer rubrum", "Vulpes vulpes", "Salix babylonica", "Odocoileus virginianus", "Betula alleghaniensis", "Rangifer tarandus","Juniperus occidentalis", "Pinus strobus"))

## ----downto.tree, echo=TRUE, fig.height=4, fig.width=6, message=FALSE, warning=TRUE----
downto.tree("Canidae", "species")

