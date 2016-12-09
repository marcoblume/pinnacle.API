#' Get Settled Special Fixtures
#'
#' @param sportid 
#' @param leagueids 
#' @param since 
#'
#' @return a data.frame of settled special fixtures
#' @export
#' @import data.table
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