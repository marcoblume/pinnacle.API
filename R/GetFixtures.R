#' Get Fixtures
#'
#' @param sportid An integer giving the sport. If this is missing in interactive mode, a menu of options is presented to the user.
#' @param leagueids (optional) integer vector with league IDs.
#' @param eventids (optional) integer vector with event IDs.
#' @param since (optional) numeric this is used to receive incremental updates.
#' Use the value of `last` from previous fixtures response.
#' @param islive Default=FALSE, boolean if TRUE retrieves ONLY live events if FALSE retrieved all events
#'
#' @return returns a data frame with columns:
#' \itemize{
#' \item SportID
#' \item Last
#' \item League
#' \item LeagueID
#' \item EventID
#' \item StartTime
#' \item HomeTeamName
#' \item AwayTeamName
#' \item Rotation Number
#' \item Live Status
#' \item Status
#' \item Parlay Status
#' }
#' @import httr
#' @import data.table
#' @importFrom jsonlite fromJSON
#' @export
#'
#' @examples
#' \donttest{
#' SetCredentials("TESTAPI", "APITEST")
#' AcceptTermsAndConditions(accepted=TRUE)
#' GetFixtures(sportid = 41, leagueids = 191545)}

GetFixtures <-
  function(sportid,
           leagueids=NULL,
           eventids=NULL,
           since=NULL,
           islive=0){

    CheckTermsAndConditions()

    # In interactive mode, try to retrieve a missing sportid parameter.
    if(interactive() && missing(sportid)) {
      cat('No Sports Selected, choose one:\n')
      ViewSports()
      sportid <- readline('Selection (id): ')
    } else if (missing(sportid)) {
      stop("missing sport ID")
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
      # If there is no content, return an empty data frame.
      # TODO: Give this the correct columns.
      data.frame()
    }
  }

