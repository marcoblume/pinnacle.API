#' GetInrunning
#'
#' @return A dataframe containing the current State of live events
#' @import httr
#' @import data.table
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
  CheckTermsAndConditions()
  sprintf('%s/v1/inrunning', .PinnacleAPI$url) %>%
    GET(add_headers(Authorization= authorization(),
                    "Content-Type" = "application/json")) %>%
    content(type = 'text') %>%
    jsonlite::fromJSON(flatten = TRUE) %>%
    as.data.table() %>%
    with({
      if(all(sapply(.,is.atomic))) .
      expandListColumns(.)
    }) %>%
    with({
      if(all(sapply(.,is.atomic))) .
      expandListColumns(.)
    })
  
}