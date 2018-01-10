#' Check the Pinnacle API's Betting Status
#'
#' Checks whether betting through the API is currently enabled. Betting,
#' particularly betting on live events, may be closed during maintenance.
#'
#' @details
#'
#' This function will raise an error if the API does not return HTTP status
#' \code{OK}. For information on the possible errors, see the API documentation
#' for \href{https://pinnacleapi.github.io/betsapi#tag/Betting-Status}{Get Betting Status}.
#'
#' @return
#'
#' A string containing the betting status of the API, which should be one of
#'
#' \itemize{
#'   \item \code{ALL_BETTING_ENABLED}
#'   \item \code{ALL_LIVE_BETTING_CLOSED}
#'   \item \code{ALL_BETTING_CLOSED}
#' }
#'
#' @examples
#' \donttest{
#' SetCredentials("TESTAPI", "APITEST")
#' AcceptTermsAndConditions(accepted = TRUE)
#' GetBettingStatus()
#' }
#'
#' @export
GetBettingStatus <- function() {
  CheckTermsAndConditions()

  response <- httr::GET(paste0(.PinnacleAPI$url, "/v1/bets/betting-status"),
                        httr::add_headers(Authorization = authorization()),
                        httr::accept_json())

  CheckForAPIErrors(response)

  response <- httr::content(response, type = "text", encoding = "UTF-8")
  jsonlite::fromJSON(response)$status
}
