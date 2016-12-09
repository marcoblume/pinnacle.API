#' Get Special Fixtures
#'
#' @param sportid 
#' @param leagueids 
#' @param category 
#' @param eventid 
#' @param specialid 
#' @param since 
#'
#' @return a data.frame of settled special fixtures
#' @export
#' @import data.table
GetSpecialFixtures <- function(sportid, 
                               leagueids = NULL, 
                               category = NULL,
                               eventid = NULL,
                               specialid = NULL,
                               since = NULL) {
  
          if(missing(sportid)) {
            sportid <- 
              GetSports(force = is.null(.PinnacleAPI$sports)) %>%
              with({
                cat('No Sport Selected, select one:\n')
                cat(paste(sprintf('%s - %s',.$id, .$name),collapse = '\n'))
                readline('Selection (id): ')
              })
          }
  r <- sprintf('%s/v1/fixtures/special',.PinnacleAPI$url) %>%
    GET(add_headers(Authorization= authorization(),
                    "Content-Type" = "application/json"),
        query = list(sportId=sportid,
                     leagueIds = if(!is.null(leagueids)) paste(leagueids,collapse=',') else NULL,
                     category = category,
                     eventId = eventid,
                     specialId = specialid,
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