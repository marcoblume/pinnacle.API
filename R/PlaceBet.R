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
#' @import httr
#' @importFrom rjson toJSON
#' @import uuid
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
  function(
           stake,
           sportId,
           eventId,
           periodNumber,
           lineId,
           betType,
           altLineId=NULL,
           team=NULL,
           side=NULL,
           acceptBetterLine=TRUE,
           winRiskStake="RISK",
           oddsFormat="AMERICAN"){

    CheckTermsAndConditions()
    place_bet_data <- list(uniqueRequestId=UUIDgenerate(),
                           acceptBetterLine=acceptBetterLine,
                           oddsFormat=oddsFormat,
                           stake=stake,
                           winRiskStake=winRiskStake,
                           sportId=sportId,
                           eventId=eventId,
                           periodNumber=periodNumber,
                           betType=betType,
                           lineId=lineId,
                           altLineId=altLineId,
                           team=team,
                           side=side)
    place_bet_body <-  rjson::toJSON(place_bet_data)
    
    
    r <- POST(paste0(.PinnacleAPI$url ,"/v1/bets/place"),
              add_headers(Authorization= "Basic TklDS0pCT1Q6bmo0NTc4",
                          "Content-Type" = "application/json"),
              body = place_bet_body
    )
    jsonlite::fromJSON(content(r,type="text"))

  }


PlaceBet <- 
function (stake, sportId, eventId, periodNumber, lineId, betType, 
          altLineId = NULL, team = NULL, side = NULL, acceptBetterLine = TRUE, 
          winRiskStake = "RISK", oddsFormat = "AMERICAN") {
  CheckTermsAndConditions()
  place_bet_data <- list(uniqueRequestId = UUIDgenerate(), 
                         acceptBetterLine = acceptBetterLine, oddsFormat = oddsFormat, 
                         stake = stake, winRiskStake = winRiskStake, sportId = sportId, 
                         eventId = eventId, periodNumber = periodNumber, betType = betType, 
                         lineId = lineId, altLineId = altLineId, team = team, 
                         side = side)
  place_bet_body <- rjson::toJSON(place_bet_data)
  r <- httr::POST(paste0(.PinnacleAPI$url, "/v1/bets/place"), add_headers(Authorization = authorization(), 
                                                                    `Content-Type` = "application/json"), body = place_bet_body)
  jsonlite::fromJSON(content(r, type = "text"))
}