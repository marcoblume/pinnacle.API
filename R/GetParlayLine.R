#' Get Parlay Lines for a Given Leg List
#'
#' Queries the available lines for a series of parlay legs and calculates the
#' relevant odds.
#'
#' @param legs A list of parlay legs. See Details.
#' @param oddsformat Format for the returned odds. One of \code{"AMERICAN"},
#'   \code{"DECIMAL"}, \code{"HONGKONG"}, \code{"INDONESIAN"}, or
#'   \code{"MALAY"}.
#'
#' @details
#'
#' Each parlay leg must be a named list containing the \code{eventId},
#' \code{periodNumber}, and \code{legBetType} (which is one of \code{"SPREAD"},
#' \code{"MONEYLINE"}, or \code{"TOTAL_POINTS"}).
#'
#' The parlay legs must also contain the fields \code{team}, \code{side}, and
#' \code{handicap}, depending on the particular bet type. These fields accept
#' the same formats as other functions in this package. See the examples below.
#'
#' This function will raise an error if the API does not return HTTP status
#' \code{OK}. For information on the possible errors, see the API documentation
#' for \href{https://pinnacleapi.github.io/#operation/Line_Parlay_V1_Post}{Get Parlay Line}.
#'
#' @return
#'
#' A list of lines, which will be empty if there are none. The list contains
#' information on the validity of the parlay (in \code{status}), the minimum
#' and maximum risk, and the error (if present). It will also contain a list
#' of possible round robin options and their associated odds, and a list of
#' validated legs. Importantly, these legs contain the \code{lineId} entries
#' that are needed to actually place the parlay bet.
#'
#' @examples
#' SetCredentials("TESTAPI", "APITEST")
#' AcceptTermsAndConditions(accepted = TRUE)
#'
#' # Define three parlay legs.
#'
#' leg1 <- list(eventId = 620550552, periodNumber = 0,
#'              legBetType = "MONEYLINE", team = "DRAW")
#'
#' leg2 <- list(eventId = 620671010, periodNumber = 0,
#'              legBetType = "TOTAL_POINTS", side = "OVER",
#'              handicap = 2.5)
#'
#' leg3 <- list(eventId = 620671010, periodNumber = 0,
#'              legBetType = "SPREAD", team = "TEAM1",
#'              handicap = -0.5)
#'
#' \dontrun{
#'
#' # Since leg 2 and 3 are from the same game, they will be rejected
#' # for betting as correlated:
#' GetParlayLine(list(leg2, leg3))
#'
#' # But leg 1 and 2 should be fine:
#' lines <- GetParlayLine(list(leg1, leg2))
#'
#' # You must use the lineIds before placing bets.
#' leg1$lineId <- lines$legs$lineId[1]
#' leg2$lineId <- lines$legs$lineId[2]
#'
#' bet <- PlaceParlayBet(riskAmount = 50,
#'                       legslist = list(leg1, leg2),
#'                       roundRobinOptions = "Parlay",
#'                       oddsFormat = "AMERICAN" ,
#'                       acceptBetterLine = TRUE)
#' }
#'
#' @export
GetParlayLine <- function(legs, oddsformat = "AMERICAN") {
  CheckTermsAndConditions()

  for (i in 1:length(legs)) {
    legs[[i]]$uniqueLegId <- uuid::UUIDgenerate()
  }

  request_body <- jsonlite::toJSON(list(oddsFormat = oddsformat, legs = legs),
                                   auto_unbox = TRUE, null = "null")

  response <- httr::POST(paste0(.PinnacleAPI$url, "/v1/line/parlay"),
                         httr::add_headers(Authorization = authorization(),
                                           "Content-Type" = "application/json"),
                         httr::accept_json(),
                         body = request_body)

  CheckForAPIErrors(response)

  # If no rows are returned, return empty data.frame
  if (!httr::has_content(response)) return(list())

  httr::content(response, type = "text", encoding = "UTF-8") %>%
    jsonlite::fromJSON()
}
