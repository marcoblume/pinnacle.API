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
    
    ## retrieve sportid
    if (missing(sportid)) {
      cat('No Sports Selected, choose one:\n')
      ViewSports()
      sportid <- readline('Selection (id): ')
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
    
    r <- 
      sprintf('%s/v1/odds', .PinnacleAPI$url) %>%
      modify_url(
        query = 
          list(
            sportId = sportid,
            leagueIds = if (!is.null(leagueids)) paste(leagueids, collapse = ',') else NULL,
            since = since,
            isLive = islive*1L,
            oddsFormat = oddsformat)
      ) %>%
      httr::GET(add_headers(Authorization = authorization(),
                      "Content-Type" = "application/json")) %>%
      content(type = "text", encoding = "UTF-8")
    
    
    # If no rows are returned, return empty data.frame
    if (identical(r, '')) return(data.frame())
    
    r %>%
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


