#' Place Bet
#'
#' Place bet in the system
#'
#' @param acceptBetterLine Default=TRUE ,boolean Whether or not to accept a bet
#'  when there is a line change in favor of the client
#' @param oddsFormat Default="AMERICAN", Desired Odds Format
#' \itemize{
#' \item{AMERICAN}
#' \item{DECIMAL}
#' \item{HONGKONG}
#' \item{INDONESIAN}
#' \item{MALAY}
#' }
#' @param stake numeric Wager amount in  currency
#' @param winRiskStake Default="RISK", either place the stake to RISK/WIN
#'  \itemize{
#' \item{WIN}
#' \item{RISK}
#' }
#' @param sportId numeric the sport id
#' @param eventId numeric the vent id
#' @param periodNumber numeric Number of the period , see Pinnacle API manual
#' @param betType BET_TYPE
#' \itemize{
#' \item{SPREAD	}
#' \item{MONEYLINE}
#' \item{TOTAL_POINTS}
#' \item{TEAM_TOTAL_POINTS}
#' }
#' @param lineId numeric ID of the line
#' @param altLineId numeric ID of the alternate line (lineID must also be included)
#' @param team Default = NULL , , see Pinnacle API manual
#' \itemize{
#' \item{TEAM1}
#' \item{TEAM2}
#' \item{DRAW}
#' }
#' @param side Defaulat = NULL , , see Pinnacle API manual
#' \itemize{
#' \item{OVER}
#' \item{UNDER}
#' }
#' @return list containing :
#' \itemize{
#'   \item{status}  If Status is PROCESSED_WITH_ERROR errorCode will be in the response
#'   \item{errorCode}
#' }
#' @export
#' @examples
#' \donttest{
#' SetCredentials("TESTAPI","APITEST")
#' AcceptTermsAndConditions(accepted=TRUE)
#' PlaceBet (stake=10,
#'           sportId=1,
#'           eventId=495418854,
#'           periodNumber=0,
#'           lineId=222136736,
#'           betType="MONEYLINE",
#'           team="TEAM2",
#'           acceptBetterLine=TRUE,
#'           winRiskStake="WIN",
#'           oddsFormat="AMERICAN")}
PlaceBet <- 
function (
  stake, sportId, eventId, 
  periodNumber, lineId, betType, 
  altLineId = NULL, 
  team = NULL, 
  side = NULL, 
  acceptBetterLine = TRUE, 
  winRiskStake = "RISK", 
  oddsFormat = "AMERICAN"
) {
  CheckTermsAndConditions()
  
  message(
    Sys.time(),
    '| Placing Bet - stake: ', stake,
    ' WinOrRisk: ', winRiskStake,
    ' sportid: ', sportId,
    ' eventid: ', eventId,
    ' periodnumber: ', periodNumber,
    ' lineid: ', lineId,
    ' bettype: ', betType,
    if (!is.null(altLineId)) sprintf(' altLineId: %s ', altLineId),
    if (!is.null(team)) sprintf(' team: %s ', team),
    if (!is.null(side)) sprintf(' side: %s ', side),
    if (!is.null(acceptBetterLine)) sprintf(' acceptBetterLine: %s ', acceptBetterLine),
    ' oddsformat: ', oddsFormat
  )

  bet <- list(uniqueRequestId = uuid::UUIDgenerate(),
              acceptBetterLine = acceptBetterLine,
              oddsFormat = oddsFormat,
              stake = stake,
              winRiskStake = winRiskStake,
              sportId = sportId,
              eventId = eventId,
              periodNumber = periodNumber,
              betType = betType,
              lineId = lineId,
              altLineId = altLineId,
              team = team,
              side = side)

  request_body <- rjson::toJSON(bet)
  response <- httr::POST(paste0(.PinnacleAPI$url, "/v1/bets/place"),
                         httr::add_headers(Authorization = authorization(),
                                           `Content-Type` = "application/json"),
                         httr::accept_json(),
                         body = request_body)

  CheckForAPIErrors(response)

  response <- httr::content(response, type = "text", encoding = "UTF-8")
  jsonlite::fromJSON(response)
}
