# Read test server/account parameters from a YAML file, so that they can be
# kept out of the sources.
config <- yaml::read_yaml("test_config.yaml")

incomplete_config <- function() {
  any(sapply(config, is.null))
}

if (!incomplete_config()) {
  pinnacle.API::AcceptTermsAndConditions(TRUE)
  pinnacle.API::SetCredentials(config$username, config$password)
  pinnacle.API::SetAPIEndpoint(config$url)
}

# Basic API Functionality -----------------------------------------------------
testthat::context("Basic API Functionality")

testthat::skip_if(incomplete_config(), "Incomplete test configuration file.")

testthat::test_that("API calls fail when terms are not explicitly accepted", {
  pinnacle.API::AcceptTermsAndConditions(FALSE)
  on.exit(pinnacle.API::AcceptTermsAndConditions(TRUE))

  testthat::expect_error(
    pinnacle.API::AcceptTermsAndConditions("invalid"),
    regexp = "is not TRUE"
  )

  testthat::expect_error(
    pinnacle.API::GetBettingStatus(),
    regexp = "Error: please accept terms and conditions to continue"
  )
})

testthat::test_that("API calls fail on invalid credentials", {
  pinnacle.API::SetCredentials(config$username, "badpassword")
  on.exit(pinnacle.API::SetCredentials(config$username, config$password))

  testthat::expect_error(
    pinnacle.API::GetBettingStatus(),
    regexp = "Authorization failed, invalid credentials."
  )
})

testthat::test_that("GetBettingStatus() returns the expected format", {
  status <- pinnacle.API::GetBettingStatus()
  testthat::expect_true(status %in% c("ALL_BETTING_ENABLED",
                                      "ALL_LIVE_BETTING_CLOSED",
                                      "ALL_BETTING_CLOSED"))
})
