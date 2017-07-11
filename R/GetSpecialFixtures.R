#' Get Special Fixtures
#'
#' @param sportid (optional) an integer giving the sport, if missing, a menu of options is presented
#' @param leagueids (optional) integer vector with league IDs.
#' @param category (optional) See API Manual
#' @param eventid (optional) Associated event ID
#' @param specialid (optional) Associated special ID
#' @param since (optional) numeric This is used to receive incremental updates.
#' Use the value of last from previous fixtures response.
#'
#' @return a data.frame of special fixtures
#' @export
#' @import data.table
#' @examples
#' \donttest{
#' SetCredentials("TESTAPI", "APITEST")
#' AcceptTermsAndConditions(accepted=TRUE)
#' GetSpecialFixtures()}
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
  
  message(
    Sys.time(),
    '| Pulling Special Fixtures for - sportid: ', sportid,
    if (!is.null(leagueids)) sprintf(' leagueids: %s', paste(leagueids, collapse = ', ')),
    if (!is.null(since)) sprintf(' since: %s', since),
    if (!is.null(category)) sprintf(' category: %s', category),
    if (!is.null(eventid)) sprintf(' eventid: %s', eventid),
    if (!is.null(specialid)) sprintf(' specialid: %s', specialid)
  )
  
  r <- sprintf('%s/v1/fixtures/special',.PinnacleAPI$url) %>%
    GET(add_headers(Authorization= authorization(),
                    "Content-Type" = "application/json"),
        query = list(sportId=sportid,
                     leagueIds = if(!is.null(leagueids)) paste(leagueids,collapse=',') else NULL,
                     category = category,
                     eventId = eventid,
                     specialId = specialid,
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