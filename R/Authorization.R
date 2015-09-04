#' Authorization for the Pinnacle API
#'
#' @param user Pinnacle Username
#' @param pwd  Pinnacle Password
#'
#' @import RCurl
#'
authorization <- function (user = as.character(GetCredentials()$Value[1]),
pwd = as.character(GetCredentials()$Value[2])){
    
    CheckTermsAndConditions()
  
    credentials = paste(user,pwd,sep=":")
    credentials.r = charToRaw(enc2utf8(credentials))
    paste0("Basic ", base64Encode(credentials.r, "character"))

  }

