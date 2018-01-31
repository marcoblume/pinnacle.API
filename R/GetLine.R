#' Get Lines 
#' (Use to get more detail on a single line, but the GetOdds or showOddsDF versions are intended for large amounts of data)
#' @param sportid The sport ID 
#' @param leagueids integer vector of leagueids.
#' @param eventid numeric xxxxx
#' @param periodnumber xxxxx
#' @param betType xxxx
#' @param team xxxx
#' @param side xxx
#' @param handicap xxx
#' @param oddsFormat xxx
#' @param force passed along to GetSports
#'
#' @return returns a data frame with columns:
#' \itemize{
#' \item SportID
#' \item Last
#' \item League
#' \item LeagueID
#' \item EventID
#' \item StartTime
#' \item HomeTeamName
#' \item AwayTeamName
#' \item Rotation Number
#' \item Live Status
#' \item Status
#' \item Parlay Status
#' }
#' @import httr
#' @import data.table
#' @importFrom jsonlite fromJSON
#' @export
#'
#' @examples
#' \donttest{
#' SetCredentials("TESTAPI","APITEST")
#' AcceptTermsAndConditions(accepted=TRUE)
#'  GetLine(sportId=1,leagueids=191545,eventId=495418854,
#'  periodNumber=0,team="TEAM1",betType="Moneyline")}
#'

GetLine <- function(sportid, leagueids, eventid,
                    periodnumber, betType,
                    team=NULL,
                    side=NULL,
                    handicap=NULL,
                    oddsFormat="AMERICAN",
                    force = TRUE)
{
  
  CheckTermsAndConditions()
  if (missing(sportid)) {
    cat('No Sports Selected, choose one:\n')
    ViewSports(force = force)
    sportid <- readline('Selection (id): ')
  }
  
  if (missing(leagueids)) {
    cat('No Leagues Selected, choose:\n')
    ViewLeagues(force = force)
    leagueids <- readline('Selection (id): ')
  }
  message(
    Sys.time(),
    '| Pulling line - sportid: ', sportid,
    ' leagueids: ', leagueids, 
    ' eventid: ', eventid,
    ' betType: ', betType,
    if (!is.null(team)) sprintf(' team: %s', team),
    if (!is.null(side)) sprintf(' side: %s', side),
    if (!is.null(handicap)) sprintf(' handicap: %s', handicap),
    ' oddsFormat: ', oddsFormat
  )

  response <- httr::GET(paste0(.PinnacleAPI$url, "/v1/line"),
                        httr::add_headers(Authorization = authorization()),
                        httr::accept_json(),
                        query = list(sportId = sportid,
                                     leagueId = leagueids,
                                     eventId = eventid,
                                     periodNumber = periodnumber,
                                     betType = betType,
                                     team = team,
                                     side = side,
                                     handicap = handicap,
                                     oddsFormat = oddsFormat))

  CheckForAPIErrors(response)

  response <- httr::content(response, type = "text", encoding = "UTF-8")
  jsonlite::fromJSON(response)
}
