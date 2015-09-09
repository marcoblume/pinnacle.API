#' Get the list of supported Currencies
#'
#' @param force  Default=FALSE, boolean if TRUE force a reload of the data if FALSE use cached data
#' @return  a data frame with these columns:
#' \itemize{
#' \item Currency Code
#' \item Exchange Rate to USD
#' \item Currency Name
#' }
#' @import httr
#' @import XML
#' @export
#'
#' @examples
#' \donttest{
#' SetCredentials("TESTAPI","APITEST")
#' AcceptTermsAndConditions(accepted=TRUE)
#' GetCurrencies()}
GetCurrencies <-
  function(force=FALSE){
    CheckTermsAndConditions()
    if(length(.PinnacleAPI$currencies)==0 || force){
      r <- GET(paste0(.PinnacleAPI$url ,"/v1/currencies"),
               add_headers("Authorization"= authorization())
      )
      dc <- xmlParse(content(r, "text"))
      xml_path <- "/rsp/currencies/currency"
      .PinnacleAPI$currencies <-
        data.frame("CurrencyCode"=xpathSApply(dc,xml_path,xmlGetAttr,"code"),
                   "ExchangeRateToUSD"=xpathSApply(dc,xml_path,xmlGetAttr,"rate"),
                   "CurrencyName" = xpathSApply(dc,xml_path,xmlValue),
                   check.names = FALSE,
                   stringsAsFactors = FALSE)
    }

    return(.PinnacleAPI$currencies)
  }
