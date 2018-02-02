#' Get Non-Settled Events for a Given Sport
#'
#' Queries the event listing for a given sport, which can be filtered by league
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
#'
#' @details
#'
#' This function will raise an error if the API does not return HTTP status
#' \code{OK}. For information on the possible errors, see the API documentation
#' for \href{https://pinnacleapi.github.io/#operation/Fixtures_V1_Get}{Get Fixtures}.
#'
#' @return
#'
#' A data frame with rows containing matching events and columns containing
#' sport, league, and event information. Not all sports return the same listing
#' format -- in particular, only baseball listings will have pitcher
#' information.
#'
#' @examples
#' \donttest{
#' SetCredentials("TESTAPI", "APITEST")
#' AcceptTermsAndConditions(accepted=TRUE)
#' GetFixtures(sportid = 41, leagueids = 191545)}
#'
#' @seealso
#'
#' See \code{\link{GetSettledFixtures}} to retrieve settled events, or
#' \code{\link{GetSpecialFixtures}} to retrieve special contestants for a sport.
#'
#' @import data.table
#' @export
GetFixtures <-
  function(sportid,
           leagueids=NULL,
           eventids=NULL,
           since=NULL,
           islive=FALSE){

    CheckTermsAndConditions()

    # In interactive mode, try to retrieve a missing sportid parameter.
    if(interactive() && missing(sportid)) {
      cat('No Sports Selected, choose one:\n')
      ViewSports()
      sportid <- readline('Selection (id): ')
    } else if (missing(sportid)) {
      stop("missing sport ID")
    }

    if (length(sportid) > 1) {
      stop("Only one sport can be specified at a time.")
    }

    message(Sys.time(), "| Pulling Fixtures for Sport ID: ", sportid,
            if (!is.null(leagueids)) paste(", with League ID(s):",
                                           paste(leagueids, collapse = ", ")),
            if (!is.null(eventids)) paste(", and Event ID(s):",
                                          paste(eventids, collapse = ", ")))

    # Construct URL parameter list.
    params <- list(sportId = sportid, since = since,
                   isLive = as.integer(islive))
    if (!is.null(leagueids)) {
      params$leagueIds <- paste(leagueids, collapse = ",")
    }
    if (!is.null(eventids)) {
      params$eventIds <- paste(eventids, collapse = ",")
    }

    response <- httr::GET(paste0(.PinnacleAPI$url, "/v1/fixtures"),
                          httr::add_headers(Authorization = authorization()),
                          httr::accept_json(),
                          query = params)

    CheckForAPIErrors(response)

    if (httr::has_content(response)) {
      httr::content(response, type = "text", encoding = "UTF-8") %>%
        jsonlite::fromJSON(flatten = TRUE) %>%
        as.data.table() %>%
        expandListColumns() %>%
        as.data.frame()
    } else {
      # If there is no content, return a zero-row data frame. This attempts to
      # set the columns correctly, but may not be future-proof, and does not
      # include pitchers. Still -- some column names is still much more
      # informative than no column names at all.

      # Bypass the data.frame() function purely for the 5x speed up on known,
      # valid columns.
      structure(list(
        sportId = integer(), last = integer(), league.id = integer(),
        league.name = character(), league.events.id = integer(),
        league.events.starts = character(), league.events.home = character(),
        league.events.away = character(), league.events.rotNum = character(),
        league.events.liveStatus = integer(),
        league.events.status = character(),
        league.events.parlayRestriction = integer()
      ), class = "data.frame")
    }
  }
