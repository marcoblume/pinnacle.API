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
  
  message(Sys.time(),
          '| Pulling Inrunning (Live) State')
  
  sprintf('%s/v1/inrunning', .PinnacleAPI$url) %>%
    GET(add_headers(Authorization = authorization(),
                    "Content-Type" = "application/json")) %>%
    content(type = 'text', encoding = "UTF-8") %>%
    jsonlite::fromJSON(flatten = TRUE) %>%
    as.data.table() %>%
    {
      if (all(sapply(.,is.atomic))) .
      expandListColumns(.)
    } %>%
    {
      if (all(sapply(.,is.atomic))) .
      expandListColumns(.)
    } %>%
    .[]
}