#' Get Leagues for Sport(s) by ID
#'
#' Returns all Leagues for the Sport(s) 
#'
#' @param sportid integer vector of sports IDs
#' @param force boolean whether to get new data (TRUE) or use cached data (FALSE)
#'
#' @return  a data frame having columns:
#' \itemize{
#' \item LeagueID
#' \item LinesAvailable
#' \item HomeTeam
#' \item AllowRoundRobin
#' \item LeagueName
#' }
#' @import httr
#' @import data.table
#' @export
#' 
#' @examples 
#' \donttest{
#' SetCredentials("TESTAPI","APITEST")
#' AcceptTermsAndConditions(accepted=TRUE)
#' GetLeaguesByID(1)}

GetLeaguesByID <-
  function(sportid, force = TRUE) {
    CheckTermsAndConditions()
    

    if(missing(sportid)) {
      cat('No Sports Selected, choose one:\n')
      ViewSports()
      sportid <- readline('Selection (id): ')
    }
    if (is.null(.PinnacleAPI$leagueIds) || force) {
      message(Sys.time(),
              '| Pulling new league ids for sportid: ', sportid)
        # Generate url
        sprintf('%s/v2/leagues',.PinnacleAPI$url) %>%
        # Add Headers
        GET(add_headers("Authorization" = authorization()),
            query = list(sportid = sportid)) %>%
        # Extract content
        content(type = 'text', encoding = "UTF-8") %>%
        # Convert to data.frame
        jsonlite::fromJSON() %>%
        # Return leagues field
        as.data.table() %>%
        {
          if (all(sapply(.,is.atomic))) .
          else expandListColumns(.)
        } %>%
        {
          if (all(sapply(.,is.atomic))) .
          else expandListColumns(.)
        } %T>%
        {
          # assign data to cache
          .PinnacleAPI$leagueIds <- .
        }
    }
    
    # If cached, just take cached data
    .PinnacleAPI$leagueIds
    
  }