#' showOddsDF - Takes a GetOdds JSON response and turns it into a data.frame
#'
#' @param sportname The sport name for which to retrieve the fixutres
#' @param leagueIds numeric vector of leagueids - can get as output from GetLeagues
#' @param since numeric This is used to receive incremental updates.
#' Use the value of last from previous fixtures response.
#' @param isLive boolean if TRUE retrieves ONLY live events
#' @param attachLeagueNames boolean default set to true, will attach league names. Since pulling leagues requires an additional
#' JSON response, setting this to FALSE will boost speed.
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
                        attachLeagueNames=!isLive) {
  CheckTermsAndConditions()
  
  if(attachLeagueNames){
    leagues <- GetLeagues(sportname)
    if(is.null(leagueIds)) leagueIds <- leagues$LeagueID[leagues$LinesAvailable==1]
    
    leagues <- leagues[leagues$LeagueID %in% leagueIds,]
  }
  
  
  res <- GetOdds(sportname,
                 leagueIds,
                 since=since,
                 isLive=isLive)
  
  res$leagues = lapply(res$leagues, function(leagueElement) {
    leagueElement$LeagueName <- leagues$LeagueName[leagueElement$id == leagues$LeagueID]
    leagueElement
  })
  
  fixtures <- suppressWarnings(GetFixtures(sportname,
                          leagueIds,
                          since=since,
                          isLive=isLive))
  

  
  odds_DF <- fixPeriods(res,depth=5)
  odds_DF <- combineFactors(odds_DF,depth=4)
  odds_DF <- fixPeriods(odds_DF,depth=3)
  odds_DF <- combineFactors(odds_DF,depth=2)
  odds_DF <- fixPeriods(odds_DF,depth=1)
  odds_DF <- combineFactors(odds_DF,depth=0)
  
  colnames(odds_DF)[c(1:6)] = c("SportId",
                                "LastOdds",
                                "LeagueId",
                                "EventId",
                                "LineId",
                                "PeriodNumber")
  
  if(attachLeagueNames) names(odds_DF)[names(odds_DF)=="x..i.."] <- "LeagueName"
  
  fixtodds <- right_join(fixtures, odds_DF, by=c("SportID" = "SportId", 
                                                 "LeagueID" = "LeagueId", 
                                                 "EventID" = "EventId"))
  
  
  return(fixtodds)
}