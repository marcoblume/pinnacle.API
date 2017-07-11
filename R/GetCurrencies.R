#' Get the list of supported Currencies
#'
#' @param force  Default=TRUE, boolean if TRUE force a reload of the data if FALSE use cached data
#' @return  a data frame with these columns:
#' \itemize{
#' \item Currency Code
#' \item Exchange Rate to USD
#' \item Currency Name
#' }
#' @import httr
#' @export
#'
#' @examples
#' \donttest{
#' SetCredentials("TESTAPI","APITEST")
#' AcceptTermsAndConditions(accepted=TRUE)
#' GetCurrencies()}
GetCurrencies <-
  function(force=TRUE){
    CheckTermsAndConditions()
    message(Sys.time(),
            '| Pulling Currencies')
    if (length(.PinnacleAPI$currencies) == 0 || force) {
      sprintf('%s/v2/currencies',.PinnacleAPI$url) %>%
        GET(add_headers("Authorization" = authorization(),
                        'Content-Type' = 'application/json')) %>%
        content(type = 'text', encoding = "UTF-8") %>%
        jsonlite::fromJSON(flatten = TRUE) %>%
        unlist(recursive = FALSE) %>%
        as.data.frame %T>%
        with({
          .PinnacleAPI$currencies <- .
        })
    }
       

    return(.PinnacleAPI$currencies)
  }
