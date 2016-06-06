.PinnacleAPI <- new.env()
.PinnacleAPI$url <- "https://api.pinnaclesports.com"
.PinnacleAPI$accepttermsandconditions <- 'N'
.PinnacleAPI$Terms <- "This package is a GUIDELINE only. All responsibility of activity on pinnaclesports.com lies with the user of the package and NOT with the authors of the package. Especially wagers placed with the help of this packages are the sole responsibility of the user of this package. The authors and maintainers of the package are not liable or responsible in any form.Please consult http://www.pinnaclesports.com/en/api/manual#fair-use,http://www.pinnaclesports.com/api-xml/terms-and-conditions.aspx and http://www.pinnaclesports.com/en/termsandconditions"



#' Accept terms and conditions, only run once per session, must agree to terms or functions will not work
#'
#' @param accepted Default=FALSE , BOOLEAN
#'
#' @export
#'
#' @examples
#' AcceptTermsAndConditions(accepted=TRUE)
AcceptTermsAndConditions <- function(accepted=FALSE) {
  if(!accepted) {
    cat(.PinnacleAPI$Terms)
    .PinnacleAPI$accepttermsandconditions = readline(prompt = 'Do you understand and accept these terms and conditions? (Y/N):')
  } else {
    .PinnacleAPI$accepttermsandconditions = 'Y'
  }
}


#' Prompts User for Terms and Conditions, otherwise stops running function
#'
#' @return NULL
#' @export
#'
#' @examples
#' CheckTermsAndConditions()
CheckTermsAndConditions <- function () {
  if(.PinnacleAPI$accepttermsandconditions != "Y") {
    AcceptTermsAndConditions()
    if(.PinnacleAPI$accepttermsandconditions != "Y") {
      stop('Error: please accept terms and conditions to continue')
    }
  }
}

#' Set your pinnaclesports.com user credentials
#'
#' @param username  Your username
#' @param password  Your password
#'
#' @export
#'
#' @examples
#' SetCredentials("TESTAPI","APITEST")
SetCredentials <- function(username,password){
  .PinnacleAPI$credentials$user <- username
  .PinnacleAPI$credentials$pwd <- password
}

#' Sets the API endpoint to use
#'
#' @param url a url, default value is the usual API endpoint 
#'
#' @return void
#' @export
#'
#' @examples
#' SetAPIEndpoint("https://api.pinnaclesports.com)
#' SetAPIEndpoint()
SetAPIEndpoint <- function(url = "https://api.pinnaclesports.com") {
  writeLines(paste('Package endpoint changed to:',url))
  .PinnacleAPI$url <- url
}

#' Get your credential values
#'
#' @return A data.frame with your username and password
#' @export
#'
#' @examples
#' SetCredentials("TESTAPI","APITEST")
#' GetCredentials()
GetCredentials <- function() {
  type <- c("Username","Password")
  value <- c(.PinnacleAPI$credentials$user,
             .PinnacleAPI$credentials$pwd)
  df <- data.frame(Type=type,Value=value)
  return(df)
}
