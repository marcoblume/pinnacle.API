#' Get Odds for Non-Settled Events in a Given Sport
#'
#' Queries all odds offered for a given sport, which can be filtered by league
#' and/or event ID, and narrowed to include only live events.
#'
#' @param sportid An integer giving the sport. If this is missing in
#'   interactive mode, a menu of options is presented to the user.
#' @param leagueids A vector of league IDs, or \code{NULL}.
#' @param eventids A vector of event IDs, or \code{NULL}.
#' @param since To receive only listings updated since the last query, set
#'   \code{since} to the value of \code{last} from the previous fixtures
#'   response. Otherwise it will query all listings.
#' @param islive When \code{TRUE}, retrieve only live events.
#' @param oddsformat Format for the returned odds. One of \code{"AMERICAN"},
#'   \code{"DECIMAL"}, \code{"HONGKONG"}, \code{"INDONESIAN"}, or
#'   \code{"MALAY"}.
#' @param tableformat One of
#'   \itemize{
#'     \item \code{"mainlines"} for mainlines only (the default);
#'     \item \code{"long"} for a single record for each spread/total on an event; 
#'     \item \code{"wide"} for all lines as one record; or
#'     \item \code{"subtables"} all lines for spreads/totals stored as nested
#'       tables.
#'   }
#' @param force Currently ignored.
#'
#' @details
#'
#' This function will raise an error if the API does not return HTTP status
#' \code{OK}. For information on the possible errors, see the API documentation
#' for \href{https://pinnacleapi.github.io/#operation/Odds_Straight_V1_Get}{Get Odds}.
#'
#' @return A data frame of odds.
#'
#' @examples
#' \donttest{
#' SetCredentials("TESTAPI","APITEST")
#' AcceptTermsAndConditions(accepted = TRUE)
#' # We can run without parameters, and will be given a selection of sports
#' GetOdds()}
#'
#' @import data.table
#' @export
GetOdds <-
  function(sportid,
           leagueids = NULL,
           eventids = NULL,
           since = NULL,
           islive = 0,
           oddsformat = 'AMERICAN',
           tableformat = 'mainlines',
           force = TRUE){
    CheckTermsAndConditions()

    # In interactive mode, try to retrieve a missing sportid parameter.
    if(interactive() && missing(sportid)) {
      cat('No Sports Selected, choose one:\n')
      ViewSports()
      sportid <- readline('Selection (id): ')
    } else if (missing(sportid)) {
      stop("missing sport ID")
    }

    message(Sys.time(), "| Pulling Odds for - sportid: ", sportid,
            if (!is.null(leagueids)) sprintf(", with League ID(s): %s",
                                             paste(leagueids, collapse = ", ")),
            if (!is.null(eventids)) sprintf(", and Event ID(s): %s",
                                            paste(eventids, collapse = ", ")),
            if (!is.null(since)) sprintf(" since: %s", since),
            " islive: ", islive, " oddsformat: ", oddsformat, " tableformat: ",
            tableformat)

    params <- list(sportId = sportid, since = since,
                   isLive = as.integer(islive), oddsFormat = oddsformat)
    if (!is.null(leagueids)) {
      params$leagueIds <- paste(leagueids, collapse = ",")
    }
    if (!is.null(eventids)) {
      params$eventIds <- paste(eventids, collapse = ",")
    }

    response <- httr::GET(paste0(.PinnacleAPI$url, "/v1/odds"),
                          httr::add_headers(Authorization = authorization()),
                          httr::accept_json(),
                          query = params)

    CheckForAPIErrors(response)

    # If no rows are returned, return empty data.frame
    if (!httr::has_content(response)) return(data.frame())

    httr::content(response, type = "text", encoding = "UTF-8") %>%
      jsonlite::fromJSON(flatten = TRUE) %>%
      as.data.table %>%
      with({
        if (all(sapply(.,is.atomic))) .
        else expandListColumns(.)
      }) %>%
      with({
        if (all(sapply(.,is.atomic))) .
        else expandListColumns(.)
      }) %>%
      with({
        
        if (tableformat == 'mainlines') SpreadsAndTotalsMainlines(.)
        else if (tableformat == 'long')      SpreadsAndTotalsLong(.)
        else if (tableformat == 'wide')      SpreadsAndTotalsWide(.)
        else if (tableformat == 'subtables') .
        else stop("Undefined value for tableFormat, options are 'mainlines','long','wide', and 'subtables'")
      }) %>%
      as.data.frame()
  }


