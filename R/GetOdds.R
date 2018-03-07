#' Get Odds
#'
#' @param sportid (optional) The sport id for which to retrieve the fixutres
#' @param leagueids (optional) integer vector of leagueids.
#' @param since (optional) numeric This is used to receive incremental updates.
#' Use the value of last from previous response.
#' @param islive boolean if TRUE retrieves ONLY live events
#' @param oddsformat default AMERICAN, see API manual for more options
#' @param tableformat
#' \itemize{
#' \item 'mainlines' (default), only shows mainlines
#' \item 'long' for a single record for each spread/total on an event, 
#' \item 'wide' for all lines as one record, 
#' \item 'subtables' all lines for spreads/totals stored as nested tables
#' } 
#' @param force boolean if FALSE, functions using cached data will use the values since the last force
#' @return data.frame of odds
#' @export
#' @import httr
#' @import data.table
#' @importFrom jsonlite fromJSON
#' @examples
#' \donttest{
#' SetCredentials("TESTAPI","APITEST")
#' AcceptTermsAndConditions(accepted = TRUE)
#' # We can run without parameters, and will be given a selection of sports
#' GetOdds()}
GetOdds <-
  function(sportid,
           leagueids = NULL,
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

    message(
      Sys.time(),
      '| Pulling Odds for - sportid: ', sportid,
      if (!is.null(leagueids)) sprintf(' leagueids: %s', paste(leagueids, collapse = ', ')),
      if (!is.null(since)) sprintf(' since: %s', since),
      ' islive: ', islive,
      ' oddsformat: ', oddsformat,
      ' tableformat: ', tableformat
    )

    params <- list(sportId = sportid, since = since,
                   isLive = as.integer(islive), oddsFormat = oddsformat)
    if (!is.null(leagueids)) {
      params$leagueIds <- paste(leagueids, collapse = ",")
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


