#' showOddsDF - Takes a GetOdds JSON response and combines with Fixtures and Inrunning
#'
#' @param sportid (optional) The sportid to get odds from, if none is given, 
#' a list of options and a prompt are provided
#' @param leagueids numeric vector of leagueids - can get as output from GetLeagues
#' @param since numeric This is used to receive incremental updates.
#' Use the value of last from previous fixtures response.
#' @param islive boolean if TRUE retrieves ONLY live events
#' @param force boolean default set to TRUE, forces a reload of the cache.
#' @param tableformat 
#' \itemize{
#' \item 'mainlines' (default), only shows mainlines
#' \item 'long' for a single record for each spread/total on an event, 
#' \item 'wide' for all lines as one record, 
#' \item 'subtables' all lines for spreads/totals stored as nested tables
#' } 
#' @param namesLength how many identifiers to use in the names, default is 3
#' @param attachLeagueInfo whether or not to include league information in the data
#' @param oddsformat default AMERICAN, see API manual for more options
#' bettable leagues
#' @return a dataframe combining GetOdds and GetFixtures data, containing NA's where levels of factors do not have a value.
#' Naming convention is as follows, Example: spread.altLineId.N is the altLineId associated with spread.hdp.(N+1) 
#' whereas spread.hdp refers to the mainline. spread.altLineId is the first alternate, and equivalent to spread.altLineId.0
#' @export
#' @import httr
#' @import data.table
#' @examples
#' \donttest{
#' SetCredentials("TESTAPI","APITEST")
#' AcceptTermsAndConditions(accepted=TRUE)
#' # Run without arguments, it will prompt you for the sport
#' showOddsDF()}
showOddsDF <- function (sportid,
                        leagueids=NULL,
                        since=NULL,
                        islive=0,
                        force = TRUE,
                        tableformat = 'mainlines',
                        namesLength = 3,
                        attachLeagueInfo = TRUE,
                        oddsformat = 'AMERICAN') {
  # Has user agreed to TOS?
  CheckTermsAndConditions()
  
  if(missing(sportid)) {
    cat('No Sports Selected, choose one:\n')
    ViewSports()
    sportid <- readline('Selection (id): ')
  }
  
  
  # Get JSON of odds
  res <- GetOdds(sportid,
                 leagueids = leagueids,
                 since=since,
                 islive=islive,
                 tableformat = tableformat,
                 oddsformat = oddsformat)
  
  # Get additional matchup details
  fixtures <- GetFixtures(sportid,
                          leagueids,
                          since=since,
                          islive=islive)
  inrunning <- GetInrunning()
  
  
  setDT(res)
  setDT(fixtures)
  setDT(inrunning)

  res %>% 
    merge(fixtures, 
          by.x = 'leagues.events.id',
          by.y = 'league.events.id', # Seriously? league vs leagues?
          all = TRUE,suffixes = c('','.Fixture')) %>%
    with({
      if('leagues.events.id' %in% names(inrunning)) {
        merge(.,inrunning[sports.id %in% sportid],
              by.x = 'leagues.events.id',
              by.y = 'sports.leagues.events.id',
              all = TRUE,
              suffixes = c('','.Inrunning'))
      } else {
        .
      }
    }) %>%
    with({
      if(attachLeagueInfo) {
        leagueinfo <- GetLeaguesByID(sportid)
        setDT(leagueinfo)
        merge(., leagueinfo, 
              by.x = 'league.id',
              by.y = 'leagues.id',
              all.x = TRUE, 
              suffixes = c('','.LeagueInfo'))
      } else {
        .
      }
    }) %>%
    FixNames(namesLength) %>%
    as.data.frame
  
  
}
