#' Get the Line for a Special Contestant
#'
#' Queries the current line and odds for a given contestant in a special.
#'
#' @param specialId The ID of the special for the contestant.
#' @param contestantId The ID of the contestant.
#' @param oddsFormat Format for the returned odds. One of \code{"AMERICAN"},
#'   \code{"DECIMAL"}, \code{"HONGKONG"}, \code{"INDONESIAN"}, or
#'   \code{"MALAY"}.
#'
#' @details
#'
#' This function will raise an error if the API does not return HTTP status
#' \code{OK}. For information on the possible errors, see the API documentation
#' for \href{https://pinnacleapi.github.io/linesapi#operation/Line_Special_V1_Get}{Get Special Line}.
#'
#' @return
#'
#' A data frame with the following columns:
#'
#' \describe{
#'   \item{\code{status}}{When a line ID is retrieved this will contain the
#'     code \code{"SUCCESS"}. Otherwise it may contain \code{"NOT_EXISTS"} or
#'     \code{"OFFLINE"}.}
#'   \item{\code{specialId}}{The ID of the special.}
#'   \item{\code{contestantId}}{The ID of the contestant.}
#'   \item{\code{minRiskStake}}{Minimum bettable risk amount.}
#'   \item{\code{maxRiskStake}}{Maximum bettable risk amount.}
#'   \item{\code{minWinStake}}{Minimum bettable win amount.}
#'   \item{\code{maxWinStake}}{Maximum bettable win amount.}
#'   \item{\code{lineId}}{Line ID needed to place a bet.}
#'   \item{\code{price}}{Latest price.}
#'   \item{\code{handicap}}{Handicap value, if applicable.}
#' }
#'
#' @examples
#' \donttest{
#' SetCredentials("TESTAPI", "APITEST")
#' AcceptTermsAndConditions(accepted = TRUE)
#'
#' # This contest is unlikely to exist, but serves as an example
#' # of the format.
#' GetSpecialLine(specialId = 101, contestantId = 102,
#'                oddsFormat = "AMERICAN")
#' }
#'
#' @seealso
#'
#' See \code{\link{GetLine}} to retrieve non-special lines,
#' \code{\link{GetSpecialFixtures}} to query available special contestants, and
#' \code{\link{PlaceSpecialBet}} to actually wager on a contestant.
#'
#' @export
GetSpecialLine <- function (specialId, contestantId, oddsFormat = "AMERICAN") {
  oddsFormat <- match.arg(oddsFormat, c("AMERICAN", "DECIMAL", "HONGKONG",
                                        "INDONESIAN", "MALAY"))
  CheckTermsAndConditions()

  response <- httr::GET(paste0(.PinnacleAPI$url, "/v1/line/special"),
                        httr::add_headers(Authorization = authorization()),
                        httr::accept_json(),
                        query = list(oddsFormat = oddsFormat,
                                     specialId = specialId,
                                     contestantId = contestantId))

  CheckForAPIErrors(response)

  response <- jsonlite::fromJSON(httr::content(response, type = "text",
                                               encoding = "UTF-8"))

  if (response$status != "SUCCESS") {
    # Because the API will not actually return any of the other columns in this
    # case, we fill them out with NAs.
    response$specialId <- as.integer(specialId)
    response$contestantId <- as.integer(contestantId)
    response$minRiskStake <- NA_real_
    response$maxRiskStake <- NA_real_
    response$lineId <- NA_integer_
    response$price <- NA_real_
    response$handicap <- NA_real_

    as.data.frame(response, stringsAsFactors = FALSE)
  } else {
    response <- as.data.frame(response, stringsAsFactors = FALSE)

    # Some contestants have handicap data, others do not -- for consistency, we
    # will add it when missing.
    if (!"handicap" %in% names(response)) {
      response$handicap <- NA_real_
    }

    response
  }
}
