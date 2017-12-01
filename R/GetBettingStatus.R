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

  request <- httr::GET(paste0(.PinnacleAPI$url, "/v1/bets/betting-status"),
                       httr::add_headers(Authorization = authorization()),
                       httr::accept_json())

  # The API won't return a JSON error code in this case, so bail out before
  # trying to parse it.
  if (httr::status_code(request) == 404) {
    stop("API request returned code 404 (Not Found).")
  }

  response <- jsonlite::fromJSON(httr::content(request, type = "text",
                                               encoding = "UTF-8"))
  # Error out on non-OK responses.
  if (httr::status_code(request) == 200) {
    response$status
  } else {
    # Attempt to signal helpful errors.
    switch(
      response$code,
      "INVALID_REQUEST_DATA" = stop("Internal error. Invalid data."),
      "INVALID_AUTHORIZATION_HEADER" =
        stop("Internal error. Missing/incomplete auth header."),
      "INVALID_CREDENTIALS" = stop("Invalid login credentials."),
      "ACCOUNT_INACTIVE" = stop("Inactive login account."),
      "NO_API_ACCESS" = stop("Login account does not have API access."),
      stop(paste0("API error: ", response$message, " (API code: ",
                  response$code, ")"))
    )
  }
}
