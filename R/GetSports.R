#' Get Sports
#'
#' Returns all sports with the status whether they currently have lines or not
#'
#' @param force Default=FALSE, boolean if TRUE force a reload of the data if FALSE use cached data
#' @return  a data frame with these columns:
#' \itemize{
#' \item SportID
#' \item LinesAvailable
#' \item SportName
#' }
#' @import httr
#' @import XML
#' @export
#'
#' @examples
#' \donttest{
#' SetCredentials("TESTAPI","APITEST")
#' AcceptTermsAndConditions(accepted=TRUE)
#' GetSports()}
GetSports <-
  function(force=FALSE){
    CheckTermsAndConditions()
    # If Force = FALSE or the SportList is Empty then load a new Sport List
    if(length(.PinnacleAPI$sports)==0 || force){
      data <- GET(paste0(.PinnacleAPI$url ,"/v1/sports"),
               add_headers("Authorization"= authorization())
      )
      sport_data <- xmlParse(content(data, "text"))
      xml_path <- "/rsp/sports/sport"
      .PinnacleAPI$sports <-
        data.frame("SportID"=xpathSApply(sport_data,xml_path,xmlGetAttr,"id"),
                   "LinesAvailable"=xpathSApply(sport_data,xml_path,xmlGetAttr,"feedContents"),
                   "SportName" = xpathSApply(sport_data,xml_path,xmlValue),
                   check.names = FALSE,
                   stringsAsFactors = FALSE)
    }
    
    .PinnacleAPI$sports
  }


