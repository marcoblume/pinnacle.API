#' Get Lines 
#' (Use to get more detail on a single line, but the GetOdds or showOddsDF versions are intended for large amounts of data)
#' @param sportId The sport ID 
#' @param leagueids integer vector of leagueids.
#' @param eventId numeric xxxxx
#' @param periodNumber xxxxx
#' @param betType xxxx
#' @param team xxxx
#' @param side xxx
#' @param handicap xxx
#' @param oddsFormat xxx
#'
#' @return returns a data frame with columns:
#' \itemize{
#' \item SportID
#' \item Last
#' \item League
#' \item LeagueID
#' \item EventID
#' \item StartTime
#' \item HomeTeamName
#' \item AwayTeamName
#' \item Rotation Number
#' \item Live Status
#' \item Status
#' \item Parlay Status
#' }
#' @import httr
#' @importFrom jsonlite fromJSON
#' @export
#'
#' @examples
#' \donttest{
#' SetCredentials("TESTAPI","APITEST")
#' AcceptTermsAndConditions(accepted=TRUE)
#'  GetLine(sportId=1,leagueids=191545,eventId=495418854,
#'  periodNumber=0,team="TEAM1",betType="Moneyline")}
#'

GetLine <- function(sportId,
                    leagueids,
                    eventId,
                    periodNumber,
                    betType,
                    team=NULL,
                    side=NULL,
                    handicap=NULL,
                    oddsFormat="AMERICAN")
{
  
  CheckTermsAndConditions()
  
  r <- GET(paste0(.PinnacleAPI$url ,"/v1/line?sportId"),
           add_headers(Authorization= authorization(),
                       "Content-Type" = "application/json"),
           query = list(sportId=sportId,
                        leagueId = paste(leagueids,collapse=','),
                        eventId=eventId,
                        periodNumber=periodNumber,
                        betType=betType,
                        team=team,
                        side=side,
                        handicap=handicap,
                        oddsFormat=oddsFormat))
  res <-  jsonlite::fromJSON(content(r,type="text"))
  
  res

  
}