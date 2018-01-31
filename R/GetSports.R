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
    if (length(.PinnacleAPI$sports) == 0 || force) {
      
      message(Sys.time(), "| Pulling Sports")

      response <- httr::GET(paste0(.PinnacleAPI$url, "/v2/sports"),
                            httr::add_headers(Authorization = authorization()),
                            httr::accept_json())

      CheckForAPIErrors(response)

      response <- httr::content(response, type = "text", encoding = "UTF-8")
      .PinnacleAPI$sports <- jsonlite::fromJSON(response)$sports
    }

    .PinnacleAPI$sports
  }
