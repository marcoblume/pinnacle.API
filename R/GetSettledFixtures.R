#' Get Settled Fixtures
#'
#' @param sportid (optional) an integer giving the sport, if missing, a menu of options is presented
#' @param leagueids (optional) integer vector with league IDs.
#' @param since (optional), numeric, This is used to receive incremental updates.
#' Use the value of `last` from previous fixtures response.
#' 
#' @return a data.frame of settled fixtures
#' @export
#' @import data.table
#' @examples
#' \donttest{
#' SetCredentials("TESTAPI", "APITEST")
#' AcceptTermsAndConditions(accepted=TRUE)
#' GetSettledFixtures()
#' }
GetSettledFixtures <- function(sportid, 
                               leagueids = NULL, 
                               since = FALSE) {
  
          if(missing(sportid)) {
            cat('No Sports Selected, choose one:\n')
            ViewSports()
            sportid <- readline('Selection (id): ')
          }
  
  message(
    Sys.time(),
    '| Pulling Settled Fixtures for - sportid: ', sportid,
    if (!is.null(leagueids)) sprintf(' leagueids: %s', paste(leagueids, collapse = ', '))
  )
  
  r <- sprintf('%s/v1/fixtures/settled',.PinnacleAPI$url) %>%
    GET(add_headers(Authorization= authorization(),
                    "Content-Type" = "application/json"),
        query = list(sportId=sportid,
                     leagueIds = if(!is.null(leagueids)) paste(leagueids,collapse=',') else NULL,
                     since=since)) %>%

    content(type="text", encoding = "UTF-8") 
  
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