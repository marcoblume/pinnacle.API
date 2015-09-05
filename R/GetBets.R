#' Get a list of running/settled bets
#'
#' @param betlist Either 'SETTLED' or 'RUNNING' Default Behavior shows both
#' @param fromDate Iso8061 Date Default: 7 days prior, Sys.Date()-7
#' @param toDate Iso8061 Date  Default: Line Close within next 7 days Sys.Date()+7
#'
#' @return A list of bets and associated details 
#' @export
#' @importFrom jsonlite fromJSON
#' @importFrom jsonlite rbind.pages
#' @examples
#' \donttest{
#' SetCredentials("TESTAPI","APITEST")
#' AcceptTermsAndConditions(accepted=TRUE)
#' GetBetsList()}
GetBetsList <-
  function(betlist = c('SETTLED','RUNNING'),
           fromDate = Sys.Date()-7,
           toDate = Sys.Date()+7){
    
    CheckTermsAndConditions()
    
    jsonlite::rbind.pages(lapply(betlist, function(betlist_type) {
        r <- GET(paste0(.PinnacleAPI$url ,"/v1/bets"),
             add_headers(Authorization= authorization(),
                         "Content-Type" = "application/json"),
             query = list(betlist=betlist_type,
                          betids=NULL,
                          fromDate=as.character(fromDate),
                          toDate=as.character(toDate)))
        res <-  jsonlite::fromJSON(content(r,type="text"))
    
        data.frame(res$bets)}))
  }
