#' Get Leagues for Sport(s) by name
#'
#'  Returns all Leagues for the Sport(s) 
#'
#' @param sports  character vector of sports names.
#' @param force Default=FALSE, boolean if TRUE force a reload of the data if FALSE use cached data
#' @param regex Default=FALSE, boolean if TRUE , retreives sports id using regular expression on names
#' @return a data frame having columns:
#' \itemize{
#' \item LeagueID
#' \item LinesAvailable
#' \item HomeTeam
#' \item AllowRoundRobin
#' \item LeagueName
#' }
#' @import data.table
#'@export
#'@examples
#'\donttest{
#' SetCredentials("TESTAPI","APITEST")
#' AcceptTermsAndConditions(accepted=TRUE)
#' GetLeagues("Badminton")}

GetLeagues <- function(sports, force = TRUE, regex = FALSE) {
  ## this is called once
  CheckTermsAndConditions()
  
  if(missing(sports)) {
    cat('No Sports Selected, choose one:\n')
    ViewSports()
    ids.search <- readline('Selection (id): ')
  } else {
    sports.all <- GetSports(force = force)
    ids <- sports.all[['id']]
    ids.search <- if(!regex) {
      ids[match(tolower(sports),tolower(sports.all[,"name"]))]
    } else {
      patt <- paste(tolower(sports),collapse='|')
      ids[grepl(patt,tolower(sports.all[,"name"]))]
    }
  }
  do.call(rbind,
          lapply(ids.search, function(id) GetLeaguesByID(id,force=force)))
}