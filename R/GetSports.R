#' Get Sports
#'
#' Returns all sports with the status whether they currently have lines or not
#'
#' @param force Default=TRUE, boolean if TRUE force a reload of the data if FALSE use cached data
#' @return  a data frame with these columns:
#' \itemize{
#' \item SportID
#' \item LinesAvailable
#' \item SportName
#' }
#' @import httr
#' @import data.table
#' @export
#'
#' @examples
#' \donttest{
#' SetCredentials("TESTAPI","APITEST")
#' AcceptTermsAndConditions(accepted=TRUE)
#' GetSports()}

GetSports <-
  function(force = TRUE) {
    CheckTermsAndConditions()
    # If Force = FALSE or the SportList is Empty then load a new Sport List
    if(length(.PinnacleAPI$sports)==0 || force) {
      sprintf("%s/v2/sports",.PinnacleAPI$url) %>%
        GET(add_headers("Authorization"= authorization())) %>%
        content(type = 'text') %>%
        jsonlite::fromJSON() %>%
        .[['sports']] %T>%
        with({
          .PinnacleAPI$sports <- .
        })
    }
    
    .PinnacleAPI$sports
  }

