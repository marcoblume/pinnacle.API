#' Get Fixtures
#'
#' @param sportid (optional) an integer giving the sport, if missing, a menu of options is presented
#' @param leagueids (optional) integer vector with league IDs.
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
           since=NULL,
           islive=0){

    CheckTermsAndConditions()
    ## retrieve sportid
    if(missing(sportid)) {
      cat('No Sports Selected, choose one:\n')
      ViewSports()
      sportid <- readline('Selection (id): ')
    }
    
    r <- 
      sprintf('%s/v1/fixtures', .PinnacleAPI$url) %>%
      GET(add_headers(Authorization= authorization(),
                      "Content-Type" = "application/json"),
          query = list(sportId=sportid,
                       leagueIds = if(!is.null(leagueids)) paste(leagueids,collapse=',') else NULL,
                       since=since,
                       isLive=islive*1L)) %>%
      content(type="text") 
    
    
    # If no rows are returned, return empty data.frame
    if(identical(r, '')) return(data.frame())
    
    r %>%
      jsonlite::fromJSON(flatten = TRUE) %>%
      as.data.table %>%
      expandListColumns() %>%
      as.data.frame()
  }

