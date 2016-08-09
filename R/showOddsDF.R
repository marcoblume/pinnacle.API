#' showOddsDF - Takes a GetOdds JSON response and turns it into a data.frame
#'
#' @param sportname The sport name for which to retrieve the fixutres
#' @param leagueIds numeric vector of leagueids - can get as output from GetLeagues
#' @param since numeric This is used to receive incremental updates.
#' Use the value of last from previous fixtures response.
#' @param isLive boolean if TRUE retrieves ONLY live events
#' @param attachLeagueNames boolean default set to true, will attach league names. 
#' @param force boolean default set to TRUE, forces a reload of the cache.
#' bettable leagues
#' @return a dataframe combining GetOdds and GetFixtures data, containing NA's where levels of factors do not have a value.
#' Naming convention is as follows, Example: spread.altLineId.N is the altLineId associated with spread.hdp.(N+1) 
#' whereas spread.hdp refers to the mainline. spread.altLineId is the first alternate, and equivalent to spread.altLineId.0
#' @export
#' @import dplyr
#' @examples
#' \donttest{
#' SetCredentials("TESTAPI","APITEST")
#' AcceptTermsAndConditions(accepted=TRUE)
#' showOddsDF(sportname="Badminton",leagueIds=191545)}
showOddsDF <- function (sportname,
                        leagueIds=NULL,
                        since=NULL,
                        isLive=0,
                        attachLeagueNames=TRUE,
                        force = TRUE) {
  # Has user agreed to TOS?
  CheckTermsAndConditions()
  
  if(missing(sportname)) stop('Error: sportname not optional')
  
  # If specific league Ids have not been given, Pull League info and set those params
  if(attachLeagueNames | is.null(leagueIds)){
    leagues <- GetLeagues(sportname,force = force)
    if(is.null(leagueIds)) leagueIds <- leagues$LeagueID[leagues$LinesAvailable==1]
    if(attachLeagueNames) leagues <- leagues[leagues$LeagueID %in% leagueIds,]
  }
  
  # Get JSON of odds
  res <- GetOdds(sportname,
                 leagueIds,
                 since=since,
                 isLive=isLive)
  
  # Conditionally add League Names to response
  if(attachLeagueNames){
    res$leagues = lapply(res$leagues, function(leagueElement) {
      leagueElement$LeagueName <- leagues$LeagueName[leagueElement$id == leagues$LeagueID]
      leagueElement
    })
  }
  
  # Get additional matchup details
  fixtures <- suppressWarnings(GetFixtures(sportname,
                                           leagueIds,
                                           since=since,
                                           isLive=isLive))
  
  # Convert res from JSON Tree to data.frame with NAs at missing factor levels
  odds_DF <- suppressWarnings(JSONtoDF(res))
  
  
  # Get any Inrunning odds
  inrunning <- suppressWarnings(GetInrunning())
  
  # Join fixtures onto odds_DF and Inrunning onto that
  fixtodds <- right_join(fixtures, odds_DF, by=c("SportID" = "sportId", 
                                                 "LeagueID" = "id", 
                                                 "EventID" = "id.1"))
  if(ncol(inrunning)>2) {
    fixtodds <- left_join(fixtodds,inrunning, by=c('SportID',
                                                   'LeagueID',
                                                   'EventID'))
  }
  
  if('number' %in% names(fixtodds)) {
    names(fixtodds)[names(fixtodds)=='number'] <- 'PeriodNumber'
  }
  
  orderNameFields <- c('StartTime',
                       'cutoff', 
                       'SportID', 
                       'LeagueID', 
                       'LeagueName', 
                       'EventID', 
                       'lineId', 
                       'PeriodNumber', 
                       'HomeTeamName', 
                       'AwayTeamName', 
                       'Status', 
                       'LiveStatus', 
                       'ParlayStatus', 
                       'RotationNumber')
  
  newOrderFields <- c(orderNameFields[orderNameFields %in% names(fixtodds)],
                      setdiff(names(fixtodds),orderNameFields[orderNameFields %in% names(fixtodds)]))
  
  fixtodds <- fixtodds[newOrderFields]
  
  
  return(fixtodds)
}