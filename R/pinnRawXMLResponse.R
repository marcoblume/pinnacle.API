#' pinnRawXMLResponse
#'
#' @return a list containing the raw and the converted XML responses
#' @export
pinnRawJSONResponse <-
  function(){
    CheckTermsAndConditions()
    
      data <- GET(paste0(.PinnacleAPI$url ,"/v1/sports"),
                  add_headers("Authorization"= authorization()))
      
      sport_data = NULL
      try(sport_data <- xmlParse(content(data, "text")))
      
    
    return(list(data = data,
                sport_data = sport_data))
  }