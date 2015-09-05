#' Get Leagues for Sport(s) by ID
#'
#' Returns all Leagues for the Sport(s) 
#'
#' @param sportid integer vector of sports IDs
#'
#' @return  a data frame having columns:
#' \itemize{
#' \item LeagueID
#' \item LinesAvailable
#' \item HomeTeam
#' \item AllowRoundRobin
#' \item LeagueName
#' }
#' @import httr
#' @import XML
#' @export
#' 
#' @examples 
#' \donttest{
#' SetCredentials("TESTAPI","APITEST")
#' AcceptTermsAndConditions(accepted=TRUE)
#' GetLeaguesByID(1)}
GetLeaguesByID <-
  function(sportid){
    CheckTermsAndConditions()
    r <- GET(paste0(.PinnacleAPI$url ,"/v1/leagues"),
             add_headers("Authorization"= authorization()),
             query = list(sportid=sportid)
    )
    dc <- xmlParse(content(r, "text"))
    xml_path <- "/rsp/leagues/league"
    data.frame("LeagueID"= xpathSApply(dc,xml_path,xmlGetAttr,"id"),
               "LinesAvailable"= xpathSApply(dc,xml_path,xmlGetAttr,"feedContents"),
               "HomeTeam" = xpathSApply(dc,xml_path,xmlGetAttr,"homeTeamType"),
               "AllowRoundRobin"= xpathSApply(dc,xml_path,xmlGetAttr,"allowRoundRobins"),
               "LeagueName"= xpathSApply(dc,xml_path,xmlValue),
               check.names  = FALSE,
               stringsAsFactors = FALSE)
  }