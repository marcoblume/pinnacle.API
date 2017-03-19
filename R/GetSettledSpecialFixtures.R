#' Get Settled Special Fixtures
#'
#' @param sportid (optional) an integer giving the sport, if missing, a menu of options is presented
#' @param leagueids (optional) integer vector with league IDs.
#' @param since (optional) numeric This is used to receive incremental updates.
#' Use the value of last from previous fixtures response.
#'
#' @return a data.frame of settled special fixtures
#' @export
#' @import data.table
#' @examples
#' \donttest{
#' SetCredentials("TESTAPI", "APITEST")
#' AcceptTermsAndConditions(accepted=TRUE)
#' # Can be run without arguments
#' GetSettledSpecialFixtures()}
GetSettledSpecialFixtures <- function(sportid, 
                               leagueids = NULL, 
                               since = NULL) {
  
          if(missing(sportid)) {
            cat('No Sports Selected, choose one:\n')
            ViewSports()
            sportid <- readline('Selection (id): ')
          }
  r <- sprintf('%s/v1/fixtures/special/settled',.PinnacleAPI$url) %>%
    GET(add_headers(Authorization= authorization(),
                    "Content-Type" = "application/json"),
        query = list(sportId=sportid,
                     leagueIds = if(!is.null(leagueids)) paste(leagueids,collapse=',') else NULL,
                     since=since)) %>%
    
    content(type="text") 
  if(identical(r, '')) return(data.frame())
  r %>%
    jsonlite::fromJSON(flatten = TRUE) %>%
    as.data.table %>%
    expandListColumns() %>%
    with({
      if(all(sapply(.,is.atomic))) .
      else expandListColumns(.)
    }) %>%
    as.data.frame()
  
}