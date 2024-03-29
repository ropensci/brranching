context("phylomatic_names")

mynames <- c("Poa annua", "Salix goodingii", "Helianthus annuus")

test_that("phylomatic_names - rsubmit works", {
  skip_on_cran()
  skip_on_ci()

  nms <- suppressMessages(phylomatic_names(mynames, format = 'rsubmit'))

  expect_is(nms, "character")
  expect_true(grepl("\\%", nms[1]))
  expect_equal(strsplit(nms[1], "\\%")[[1]][1], "poaceae")
})

test_that("phylomatic_names - isubmit (default) works", {
  skip_on_cran()
  skip_on_ci()

  nms <- suppressMessages(phylomatic_names(taxa = mynames, format = 'isubmit'))

  expect_is(nms, "character")
  expect_false(grepl("\\%", nms[1]))
  expect_true(grepl("\\/", nms[1]))
  expect_equal(strsplit(nms[1], "\\/")[[1]][1], "poaceae")
})

test_that("phylomatic_names - db=apg works", {
  skip_on_cran()
  skip_on_ci()

  nms <- suppressMessages(phylomatic_names(mynames, db = "apg"))

  expect_is(nms, "character")
  expect_false(grepl("\\%", nms[1]))
  expect_true(grepl("\\/", nms[1]))
  expect_equal(strsplit(nms[1], "\\/")[[1]][1], "poaceae")
})

test_that("phylomatic fails as expected", {
  skip_on_cran()
  skip_on_ci()

  # fails when no taxa given
  expect_error(phylomatic_names(), "argument \"taxa\" is missing")

  # fails when format isn't of allowed values
  expect_error(phylomatic_names(mynames, format = "asdfadf"),
               "'arg' should be one of")

  # fails when db isn't of allowed values
  expect_error(phylomatic_names(mynames, db = "things"),
               "'arg' should be one of")
})

test_that("phylomatic_names behaves as expected if no Entrez env var set", {
  skip_on_cran()
  skip_on_ci()

  myname <- "Salix goodingii"
  mynames <- c("Salix goodingii", "Poa annua")

  # message about key not given when key is set
  # expect_silent(phylomatic_names(myname))

  env_var <- Sys.getenv("ENTREZ_KEY")
  Sys.unsetenv("ENTREZ_KEY")

  # message about the missing key should be given
  # FIXME: ideally test that it's only given once per function call
  # expect_message(phylomatic_names(myname), "No ENTREZ API key provided")

  # only given once per function call
  # expect_message(phylomatic_names(mynames), "No ENTREZ API key provided")

  # test that it's only given once per function call
  res <- conditionz::capture_message(phylomatic_names(mynames))
  expect_equal(length(res$text), 1)


  # reset env var
  Sys.setenv("ENTREZ_KEY" = env_var)
})
