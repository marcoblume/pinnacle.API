#' GetInrunning
#'
#' @return A dataframe containing the current State of live events
#' @import httr
#' @importFrom jsonlite fromJSON
#' @export
#'
#' @examples
#' \donttest{
#' SetCredentials("TESTAPI","APITEST")
#' AcceptTermsAndConditions(accepted=TRUE)
#' GetInrunning()
#' }
GetInrunning <- function() {
  r <- GET(paste0(.PinnacleAPI$url ,"/v1/inrunning"),
           add_headers(Authorization= authorization(),
                       "Content-Type" = "application/json"))
  res <-  jsonlite::fromJSON(content(r,type="text"),simplifyVector=FALSE)
  inrunningState <- fixPeriods(res,depth = 5)
  inrunningState <- combineFactors(inrunningState,depth = 4)
  inrunningState <- fixPeriods(inrunningState,depth = 3)
  inrunningState <- combineFactors(inrunningState,depth=2)
  inrunningState <- fixPeriods(inrunningState,depth=1)
  inrunningState <- combineFactors(inrunningState,depth=0)
  
  names(inrunningState)[1:2] = c('SportID','LeagueID')
  if(length(names(inrunningState))>2) names(inrunningState)[3] = c('EventID')
  return(inrunningState)
}