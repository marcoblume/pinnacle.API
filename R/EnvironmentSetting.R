.PinnacleAPI <- new.env()
.PinnacleAPI$url <- "https://api.pinnacle.com"
.PinnacleAPI$terms_accepted <- FALSE
.PinnacleAPI$terms <- "This package is a GUIDELINE only. All responsibility of activity on pinnaclesports.com lies with the user of the package and NOT with the authors of the package. Especially wagers placed with the help of this packages are the sole responsibility of the user of this package. The authors and maintainers of the package are not liable or responsible in any form. Please consult http://www.pinnaclesports.com/en/api/manual#fair-use, http://www.pinnaclesports.com/api-xml/terms-and-conditions.aspx and http://www.pinnaclesports.com/en/termsandconditions"
.PinnacleAPI$credentials <- list()

#' Accept terms and conditions, only run once per session, must agree to terms or functions will not work
#'
#' @param accepted Default=FALSE , BOOLEAN
#'
#' @export
#'
#' @examples
#' AcceptTermsAndConditions(accepted=TRUE)
AcceptTermsAndConditions <- function(accepted=FALSE) {
  # Use a prompt in interactive sessions.
  if (missing(accepted) && interactive()) {
    message(.PinnacleAPI$terms)
    accepted <- toupper(readline(
      prompt = paste("Do you understand and accept these terms and",
                     "conditions? (Y/n): ")
    ))
    accepted <- accepted == "Y"
  }

  stopifnot(is.logical(accepted))
  message(Sys.time(), "| Terms and Conditions ",
          ifelse(accepted, "Accepted", "Rejected"))
  .PinnacleAPI$terms_accepted <- accepted
}

#' Prompts User for Terms and Conditions, otherwise stops running function
#'
#' @return NULL
#' @export
#'
#' @examples
#' CheckTermsAndConditions()
CheckTermsAndConditions <- function () {
  # Give the user a chance to accept the terms in interactive sessions.
  if (!.PinnacleAPI$terms_accepted && interactive()) {
    AcceptTermsAndConditions()
  }
  if (!.PinnacleAPI$terms_accepted) {
    stop("Error: please accept terms and conditions to continue.")
  }
}

#' Set your pinnaclesports.com user credentials
#'
#' @param username  Your username
#' @param password  Your password
#' @import openssl
#' @export
#' 
#' @examples
#' SetCredentials("TESTAPI","APITEST")
SetCredentials <- function(username,password){
  .PinnacleAPI$credentials$key <- openssl::rsa_keygen()
  .PinnacleAPI$credentials$user <- 
    encrypt_envelope(
      serialize(
        object = if(missing(username)) readline('Username: \n') else username, NULL),
      .PinnacleAPI$credentials$key)
  .PinnacleAPI$credentials$pwd <- 
    encrypt_envelope(
      serialize(
        object = if(missing(password)) openssl::askpass() else password, NULL), 
      .PinnacleAPI$credentials$key)
}

#' Sets the API endpoint to use
#'
#' @param url a url, default value is the usual API endpoint 
#'
#' @return void
#' @export
#'
#' @examples
#' SetAPIEndpoint("https://api.pinnaclesports.com")
#' SetAPIEndpoint()
SetAPIEndpoint <- function(url = "https://api.pinnaclesports.com") {
  message(paste('Package endpoint changed to:',url))
  .PinnacleAPI$url <- url
}

#' Gets the current API endpoint
#'
#' @return the currently set API endpoint
#' @export
#'
#' @examples
#' SetAPIEndpoint("https://api.pinnaclesports.com/v2/")
#' GetAPIEndpoint()
#' SetAPIEndpoint("https://api.pinnaclesports.com")
GetAPIEndpoint <- function() {
  .PinnacleAPI$url
}

#' Get your Username
#'
#' @return A String, your current username
#' @export
#'
#' @examples
#' SetCredentials("TESTAPI","APITEST")
#' GetUsername()
GetUsername <- function() {
  if (is.null(.PinnacleAPI$credentials$key) && interactive()) {
    SetCredentials()
  }
  unserialize(do.call(decrypt_envelope, c(.PinnacleAPI$credentials$user, list(.PinnacleAPI$credentials$key))))
}

#' Get your Password
#'
#' @return Current Password in plaintext
#'
GetPassword <- function() {
  if (is.null(.PinnacleAPI$credentials$key) && interactive()) {
    SetCredentials()
  }
  unserialize(do.call(decrypt_envelope, c(.PinnacleAPI$credentials$pwd, list(.PinnacleAPI$credentials$key))))
}
