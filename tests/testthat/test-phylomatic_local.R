context("phylomatic_local")

test_that("phylomatic_local - GET (default) method works", {
  skip_on_cran()
  skip_on_ci()

  taxa <- c("Poa annua", "Phlox diffusa", "Helianthus annuus")
  tree <- phylomatic_local(taxa = taxa, verbose = FALSE)

  expect_is(taxa, "character")
  expect_is(tree, "phylo")
  expect_is(tree, "phylomatic")
})

test_that("phylomatic_local - smith2011", {
  skip_on_cran()
  skip_on_ci()

  taxa <- c("Pinus mugo", "Pinus abies", "Picea meyeri", "Tsuga mertensiana")
  tree <- phylomatic_local(taxa, storedtree = 'smith2011', verbose = FALSE)

  expect_is(tree, "phylo")
  expect_is(tree, "phylomatic")
})

test_that("phylomatic_local - zanne2014", {
  skip_on_cran()
  skip_on_ci()

  taxa <- c("Pinus mugo", "Pinus abies", "Picea meyeri", "Tsuga mertensiana", 
    "Neuburgia corynocarpum", "Geniostoma borbonicum", "Strychnos darienensis")
  tree <- phylomatic_local(taxa, storedtree = 'zanne2014', verbose = FALSE)

  expect_is(tree, "phylo")
  expect_is(tree, "phylomatic")
})

test_that("phylomatic_local fails as expected", {
  skip_on_cran()

  taxa <- c("Poa annua", "Phlox diffusa", "Helianthus annuus")

  # fails when no taxa given
  expect_error(phylomatic_local(), "argument \"taxa\" is missing")

  # fails when no taxnames FALSE and improper name strings passed
  # FIXME: need to lint the taxa input better
  expect_error(phylomatic_local(taxa, taxnames = FALSE, verbose = FALSE))

  # fails when db not in allowed set
  expect_error(phylomatic_local(taxa, db = 'pear', verbose = FALSE), 
    "'arg' should be one of")

  # type checks
  expect_error(phylomatic_local(taxa, taxnames = 5, verbose = FALSE), 
    "taxnames must be of class")
  expect_error(phylomatic_local(taxa, storedtree = 5, verbose = FALSE), 
    "storedtree must be of class")
  expect_error(phylomatic_local(taxa, db = 5, verbose = FALSE), 
    "db must be of class")
  expect_error(phylomatic_local(taxa, lowercase = 5, verbose = FALSE), 
    "lowercase must be of class")
  expect_error(phylomatic_local(taxa, nodes = 5, verbose = FALSE), 
    "nodes must be of class")
  expect_error(phylomatic_local(taxa, verbose = 5), 
    "verbose must be of class")
})
