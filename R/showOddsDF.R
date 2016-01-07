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
  CheckTermsAndConditions()
  
  if(missing(sportname)) stop('Error: sportname not optional')
  # 0.18 0 0.74
  if(attachLeagueNames | is.null(leagueIds)){
    leagues <- GetLeagues(sportname,force = force)
    if(is.null(leagueIds)) leagueIds <- leagues$LeagueID[leagues$LinesAvailable==1]
    if(attachLeagueNames) leagues <- leagues[leagues$LeagueID %in% leagueIds,]
  }
  
  res <- GetOdds(sportname,
                 leagueIds,
                 since=since,
                 isLive=isLive)
  
  
  if(attachLeagueNames){
    res$leagues = lapply(res$leagues, function(leagueElement) {
      leagueElement$LeagueName <- leagues$LeagueName[leagueElement$id == leagues$LeagueID]
      leagueElement
    })
  }
  
  
  fixtures <- suppressWarnings(GetFixtures(sportname,
                                           leagueIds,
                                           since=since,
                                           isLive=isLive))
 
  odds_DF <- suppressWarnings(JSONtoDF(res))
  

  inrunning <- suppressWarnings(GetInrunning())
  fixtodds <- right_join(fixtures, odds_DF, by=c("SportID" = "sportId", 
                                                 "LeagueID" = "id", 
                                                 "EventID" = "id.1"))
  
  #fixed to deal with bug that 
  if(ncol(inrunning)>2) {
    fixtodds <- left_join(fixtodds,inrunning, by=c('SportID',
                                                   'LeagueID',
                                                   'EventID'))
  }
  names(fixtodds)[names(fixtodds)=='number'] <- 'PeriodNumber'
  
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