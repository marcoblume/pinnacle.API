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
  if(r$status_code != '200') {
    warning(paste0('API did not successfully respond to your request:\n',content(r,type = 'text')))
    return(data.frame())
  }
  res <-  jsonlite::fromJSON(content(r,type="text"),simplifyVector=FALSE)
  inrunningState <- JSONtoDF(res)
  
  # If there are no games running add a leagueID column, set it to NA
  # These need to be present for the join in showODDSDF
  
  inrunningState$SportID <- ifelse(!is.null(inrunningState$id),inrunningState$id,NA)
  inrunningState$LeagueID <- ifelse(!is.null(inrunningState$id.2),inrunningState$id.2,NA)
  inrunningState$EventID <- ifelse(!is.null(inrunningState$id.1),inrunningState$id.1,NA)
  
  # exclude badly named ids
  return(inrunningState[setdiff(names(inrunningState),c('id','id.1','id.2'))])
}