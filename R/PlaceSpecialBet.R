#' Place a Special Bet on a Given Contestant
#'
#' Place a wager on a contestant in a given special line.
#'
#' @param stake The amount to be wagered.
#' @param lineId The line to wager on. See \code{\link{GetSpecialLine}}.
#' @param specialId The ID of the special offer.
#' @param contestantId The ID of the contestant wagered on.
#' @param acceptBetterLine Whether or not to accept a bet when there is a line
#'   change in favour of this wager.
#' @param winRiskStake Whether the stake is the risk or win amount. One of
#'   \code{"RISK"} or \code{"WIN"}.
#' @param oddsFormat Format for the returned odds. One of \code{"AMERICAN"},
#'   \code{"DECIMAL"}, \code{"HONGKONG"}, \code{"INDONESIAN"}, or
#'   \code{"MALAY"}.
#'
#' @details
#'
#' This function will raise an error if the API does not return HTTP status
#' \code{OK}, which is not precisely the same as an assurance that the wager
#' was placed successfully (see the Value section). For information on the
#' possible errors, see the API documentation for
#' \href{https://pinnacleapi.github.io/betsapi#operation/Bets_Special}{Place Special Bet}.
#'
#' @return
#'
#' A data frame with the following columns:
#'
#' \describe{
#'   \item{\code{status}}{When the wager is placed this will contain code
#'     \code{"ACCEPTED"}. Otherwise it will contain code
#'     \code{"PROCESSED_WITH_ERROR"}.}
#'   \item{\code{errorCode}}{When the wager is not accepted, this column
#'     will contain a code for the particular error involved; otherwise it will
#'     be \code{NA}.}
#'   \item{\code{uniqueRequestId}}{A unique ID associated with the wager.}
#' }
#'
#' When the wager is accepted, the data frame will also contain the following:
#'
#' \describe{
#'   \item{\code{betId}}{A unique ID for the newly created bet.}
#'   \item{\code{betterLineWasAccepted}}{Whether or not the bet was accepted on
#'     a line that changed in favour of wager.}
#' }
#'
#' When the wager is not accepted, the data frame may also contain
#' \code{lineId} and \code{specialBet} columns with NA values.
#'
#' @examples
#' \donttest{
#' SetCredentials("TESTAPI", "APITEST")
#' AcceptTermsAndConditions(accepted = TRUE)
#'
#' # This contest is unlikely to exist, but serves as an example
#' # of the format.
#' line <- GetSpecialLine(specialId = 101, contestantId = 102,
#'                        oddsFormat = "AMERICAN")
#'
#' if (!is.na(line$lineId)) {
#'   PlaceSpecialBet(stake = 100, lineId = line$lineId,
#'                   specialId = 101, contestantId = 102,
#'                   acceptBetterLine = TRUE,
#'                   winRiskStake = "RISK",
#'                   oddsFormat = "AMERICAN")
#' }
#' }
#'
#' @seealso
#'
#' See \code{\link{PlaceBet}} to make non-special wagers,
#' \code{\link{GetSpecialFixtures}} to query available special contestants, and
#' \code{\link{GetSpecialLine}} to get their associated lines.
#'
#' @export
PlaceSpecialBet <- function(stake, lineId, specialId, contestantId,
                            acceptBetterLine = TRUE,
                            winRiskStake = "RISK", oddsFormat = "AMERICAN") {
  # Basic argument checking.
  winRiskStake <- match.arg(winRiskStake, c("RISK", "WIN"))
  oddsFormat <- match.arg(oddsFormat, c("AMERICAN", "DECIMAL", "HONGKONG",
                                        "INDONESIAN", "MALAY"))
  CheckTermsAndConditions()

  # Create a data frame for the bet(s).
  bets <- data.frame(uniqueRequestId = uuid::UUIDgenerate(),
                     acceptBetterLine = acceptBetterLine,
                     oddsFormat = oddsFormat,
                     stake = stake,
                     winRiskStake = winRiskStake,
                     lineId = lineId,
                     specialId = specialId,
                     contestantId = contestantId,
                     stringsAsFactors = FALSE)

  request_body <- jsonlite::toJSON(list(bets = bets), auto_unbox = TRUE)
  response <- httr::POST(paste0(.PinnacleAPI$url, "/v1/bets/special"),
                         httr::add_headers(Authorization = authorization(),
                                           `Content-Type` = "application/json"),
                         httr::accept_json(),
                         body = request_body)

  CheckForAPIErrors(response)

  response <- httr::content(response, type = "text", encoding = "UTF-8")
  jsonlite::fromJSON(response)$bets
}
