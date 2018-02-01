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

testthat::test_that("GetSports() returns the expected format", {
  sports <- pinnacle.API::GetSports(force = TRUE)
  testthat::expect_is(sports, "data.frame")
  testthat::expect_gt(nrow(sports), 0)
})

testthat::test_that("GetSports() caches correctly", {
  pinnacle.API::GetSports(force = FALSE)  # Ensure cache is present.
  pinnacle.API::SetCredentials(config$username, "badpassword")
  on.exit(pinnacle.API::SetCredentials(config$username, config$password))

  sports <- pinnacle.API::GetSports(force = FALSE)
  testthat::expect_gt(nrow(sports), 0)
})

# Straight Lines --------------------------------------------------------------
testthat::context("Straight Lines")

testthat::test_that("GetFixtures() returns the expected format", {
  fixtures <- pinnacle.API::GetFixtures(config$sport)

  testthat::expect_is(fixtures, "data.frame")
  testthat::expect_gt(nrow(fixtures), 0)

  # Pick some events to test filtering calls against.
  set.seed(101)
  events <- sample.int(nrow(fixtures), 2)
  events <- fixtures[events, c("league.id", "league.events.id")]
  names(events) <- c("league", "event")

  result <- pinnacle.API::GetFixtures(config$sport, eventids = events$event)
  testthat::expect_equal(nrow(result), 2)

  # Mismatched league/event IDs should give no results.
  result <- pinnacle.API::GetFixtures(config$sport, eventids = events$event[1],
                                      leagueids = events$league[1] + 1)
  testthat::expect_equal(nrow(result), 0)

  # Adding an invalid event ID should error.
  testthat::expect_error(
    pinnacle.API::GetFixtures(config$sport, eventids = c(-1, events$event)),
    regexp = "Invalid request parameters."
  )

  # As should the addition of a second sport.
  testthat::expect_error(
    pinnacle.API::GetFixtures(c(config$sport, 1e6), eventids = events$event),
    regexp = "Only one sport can be specified at a time."
  )

  # Some odd event IDs are allowed, though.
  result <- pinnacle.API::GetFixtures(config$sport, eventids = 0)
  testthat::expect_equal(nrow(result), 0)
})

testthat::test_that("GetLine() returns the expected format", {
  fixtures <- pinnacle.API::GetFixtures(config$sport)

  # Pick an event to test line query.
  set.seed(101)
  events <- sample.int(nrow(fixtures), 1)
  events <- fixtures[events, c("league.id", "league.events.id")]
  names(events) <- c("league", "event")

  line <- pinnacle.API::GetLine(config$sport, leagueids = events$league[1],
                                eventid = events$event[1],
                                periodnumber = 0, betType = "MONEYLINE",
                                team = "TEAM1")

  testthat::expect_is(line, "list")
  testthat::expect_true(line$status %in% c("SUCCESS", "NOT_EXISTS", "OFFLINE"))

  # Invalid event/league IDs should throw an error.
  testthat::expect_error(
    pinnacle.API::GetLine(config$sport, leagueids = -1,
                          eventid = -1,
                          periodnumber = 0, betType = "MONEYLINE",
                          team = "TEAM1"),
    regexp = "Invalid request parameters."
  )

  # As should some NULL parameters.
  testthat::expect_error(
    pinnacle.API::GetLine(config$sport, leagueids = events$league[1],
                          eventid = events$event[1],
                          periodnumber = 0, betType = "MONEYLINE"),
    regexp = "Invalid request parameters."
  )

  # Some odd event IDs are evidently OK.
  line <- pinnacle.API::GetLine(config$sport, leagueids = 1,
                                eventid = 1,
                                periodnumber = 0, betType = "MONEYLINE",
                                team = "TEAM1")

  testthat::expect_is(line, "list")
  testthat::expect_true(line$status %in% c("SUCCESS", "NOT_EXISTS", "OFFLINE"))
})

# Straight Lines --------------------------------------------------------------
testthat::context("Straight Bets")

testthat::test_that("PlaceBet() returns the expected format", {
  # Some odd parameter combinations succeed.

  bet <- pinnacle.API::PlaceBet(100, config$sport, eventId = 1, periodNumber = 0,
                                lineId = 1, betType = "MONEYLINE", team = "TEAM1")

  testthat::expect_is(bet, "list")
  testthat::expect_equal(bet$status, "PROCESSED_WITH_ERROR")

  bet <- pinnacle.API::PlaceBet(100, -config$sport, eventId = 1, periodNumber = 0,
                                lineId = 1, betType = "MONEYLINE", team = "TEAM1")

  testthat::expect_is(bet, "list")
  testthat::expect_equal(bet$status, "PROCESSED_WITH_ERROR")

  bet <- pinnacle.API::PlaceBet(100, config$sport, eventId = 1, periodNumber = -1,
                                lineId = 1, betType = "MONEYLINE", team = "TEAM1")

  testthat::expect_is(bet, "list")
  testthat::expect_equal(bet$status, "PROCESSED_WITH_ERROR")

  # Others are forbidden.

  testthat::expect_error(
    pinnacle.API::PlaceBet(100, config$sport, eventId = -1, periodNumber = 0,
                           lineId = 1, betType = "MONEYLINE", team = "TEAM1"),
    regexp = "Invalid eventId parameter value."
  )

  testthat::expect_error(
    pinnacle.API::PlaceBet(-100, config$sport, eventId = 1, periodNumber = 0,
                           lineId = 1, betType = "MONEYLINE", team = "TEAM1"),
    regexp = "Invalid stake."
  )

  testthat::expect_error(
    pinnacle.API::PlaceBet(100, config$sport, eventId = 1, periodNumber = 0,
                           lineId = -1, betType = "MONEYLINE", team = "TEAM1"),
    regexp = "Invalid lineId parameter value."
  )

  testthat::expect_error(
    pinnacle.API::PlaceBet(100, config$sport, eventId = 1, periodNumber = 0,
                           lineId = 1, betType = "MONEYLINE", team = NULL),
    regexp = "The Team is required."
  )
})
