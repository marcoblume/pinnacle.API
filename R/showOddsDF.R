#' Combine Odds, Fixture, and In-Running Information into a Single Data Frame
#'
#' Queries the event listing for a given sport and the odds offered on each
#' event. This query can be filtered by league and/or event ID, and narrowed to
#' include only live events.
#'
#' @param sportid An integer giving the sport. If this is missing in
#'   interactive mode, a menu of options is presented to the user.
#' @param leagueids A vector of league IDs, or \code{NULL}.
#' @param eventids A vector of event IDs, or \code{NULL}.
#' @param since Used to receive incremental odds updates. See
#'   \code{\link{GetOdds}}.
#' @param islive When \code{TRUE}, retrieve only live events.
#' @param force Currently ignored.
#' @param tableformat The format of the odds. See \code{\link{GetOdds}}.
#' @param namesLength The number of identifiers to use in the names.
#' @param attachLeagueInfo When \code{TRUE}, include league information in the
#'   data.
#' @param oddsformat Format for the returned odds. See \code{\link{GetOdds}}.
#' @param fixtures_since Used to receive incremental fixture updates. See
#'   \code{\link{GetFixtures}}.
#'
#' @return
#'
#' A data frame combining odds and fixtures data, containing \code{NA}s where
#' levels of factors do not have a value. Example of the naming convention:
#' \code{spread.altLineId.N} is the \code{altLineId} associated with
#' \code{spread.hdp.(N+1)}, whereas \code{spread.hdp} refers to the mainline.
#' \code{spread.altLineId} is the first alternate, and equivalent to
#' \code{spread.altLineId.0}.
#'
#' @examples
#' \donttest{
#' SetCredentials("TESTAPI","APITEST")
#' AcceptTermsAndConditions(accepted=TRUE)
#' # Run without arguments, it will prompt you for the sport
#' showOddsDF()}
#'
#' @seealso
#'
#' See \code{\link{GetOdds}}, \code{\link{GetFixtures}}, and
#' \code{\link{GetInrunning}} for the underlying API requests.
#'
#' @import data.table
#' @export
showOddsDF <- 
  function(sportid,
           leagueids=NULL,
           eventids = NULL,
           since = NULL,
           islive = 0,
           force = TRUE,
           tableformat = 'mainlines',
           namesLength = 3,
           attachLeagueInfo = TRUE,
           oddsformat = 'AMERICAN',
           fixtures_since = NULL) {
    # Has user agreed to TOS?
    CheckTermsAndConditions()
    
    if (missing(sportid)) {
      cat('No Sports Selected, choose one:\n')
      ViewSports()
      sportid <- readline('Selection (id): ')
    }
    
    
    # Get JSON of odds
    res <- GetOdds(sportid,
                   leagueids = leagueids,
                   eventids = eventids,
                   since = since,
                   islive = islive,
                   tableformat = tableformat,
                   oddsformat = oddsformat)
    
    if (NROW(res) == 0) {
      message('No odds for the given selections.')
      return(res)
    }
    
    # Get additional matchup details
    fixtures <- GetFixtures(sportid,
                            leagueids,
                            eventids = eventids,
                            since  = fixtures_since,
                            islive = islive)
    
    if (NROW(fixtures) == 0) {
      message('No fixtures for the given selections.')
      return(res)
    }
    
    inrunning <- GetInrunning()
    
    setDT(res)
    setDT(fixtures)
    setDT(inrunning)
    
    res %>% 
    {
      # Merge Fixtures if we have data
      if (NROW(fixtures) == 0) return(.)
      merge(., fixtures, 
            by.x = 'leagues.events.id',
            by.y = 'league.events.id', # Seriously? league vs leagues?
            suffixes = c('','.Fixture'))
    } %>%
      {
        # Merge Inrunning if we have data
        if (NROW(inrunning) == 0) return(.)
        if ('leagues.events.id' %in% names(inrunning)) {
          merge(.,inrunning[sports.id %in% .[['sportId']]],
                by.x = 'leagues.events.id',
                by.y = 'sports.leagues.events.id',
                all.x = TRUE,
                suffixes = c('','.Inrunning'))
        } else {
          .
        }
      } %>%
      {
        # Attach League Info if we are requested to
        out <- .
        if (attachLeagueInfo) {
          leagueinfo <- GetLeaguesByID(out[!is.na(get('sportId')), unique(get('sportId'))])
          setDT(leagueinfo)
          merge(out, leagueinfo, 
                by.x = 'league.id',
                by.y = 'leagues.id',
                all.x = TRUE, 
                suffixes = c('','.LeagueInfo'))
        } else {
          .
        }
      } %>%
      FixNames(namesLength) %>%
      as.data.frame
    
    
  }
