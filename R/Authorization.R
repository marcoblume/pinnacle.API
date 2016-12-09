#' Authorization for the Pinnacle API
#'
#' @param user Pinnacle Username
#' @param pwd  Pinnacle Password
#'
#'
authorization <- function (user,
                           pwd){
  
    CheckTermsAndConditions()
    if(missing(user)) user <- GetUsername()
    if(missing(pwd)) pwd <- GetPassword()
    credentials = paste(user,pwd,sep=":")
    credentials.r = charToRaw(enc2utf8(credentials))
    paste0("Basic ", jsonlite::base64_enc(credentials.r))

  }

