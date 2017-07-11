#' Get Client Balance
#'
#' @param force Default=TRUE , boolean if TRUE force a reload of the data if FALSE use cached data
#'
#' @return vector client balance parameter
#' @export
#'
#' @import httr
#' @importFrom jsonlite fromJSON
#' @examples
#' \donttest{
#' SetCredentials("TESTAPI","APITEST")
#' AcceptTermsAndConditions(accepted=TRUE)
#' GetClientBalance()}
GetClientBalance <- function(force = TRUE){
  CheckTermsAndConditions()
  
  message(Sys.time(),
          '| Pulling Client Balance')
  
  if (length(.PinnacleAPI$ClientBalance) == 0 || force) {
    GET(paste0(.PinnacleAPI$url ,"/v1/client/balance"),
             add_headers("Authorization" = authorization(),
                         "Content-Type" = "application/json")
    ) %>%
      content("text", encoding = "UTF-8") %>% 
      jsonlite::fromJSON(flatten = TRUE) %T>%
      with({
        .PinnacleAPI$ClientBalance <- .
      })
     
  }
  .PinnacleAPI$ClientBalance
}
