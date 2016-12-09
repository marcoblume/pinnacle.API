#' Get Teaser Odds
#'
#' @param teaserid id denoting teaser
#' @param force boolean if FALSE, functions using cached data will use the values since the last force
#' @return data.frame of odds
#' @examples
#' \donttest{
#' 
#' }
#'
GetTeaserOdds <-
  function(teaserid,
           force=TRUE){
    CheckTermsAndConditions()
    cat('Not Supported Yet.')
    return(NULL)
    ## retrieve sportid
    if(missing(sportid)) {
      cat('No Sports Selected, choose one:\n')
      ViewSports()
      sportid <- readline('Selection (id): ')
    }
    
    r <- 
      sprintf('%s/v1/odds/special', .PinnacleAPI$url) %>%
      modify_url(query = list(sportId = sportid,
                              leagueIds = if(!is.null(leagueids)) paste(leagueids,collapse=',') else NULL,
                              since = since)) %>%
      httr::GET(add_headers(Authorization= authorization(),
                      "Content-Type" = "application/json")) %>%
      content(type="text") 
    
    
    # If no rows are returned, return empty data.frame
    if(identical(r, '')) return(data.frame())
    
    r %>%
      jsonlite::fromJSON(flatten = TRUE) %>%
      as.data.table %>%
      with({
        
        if(all(sapply(.,is.atomic))) .
        expandListColumns(.)
      }) %>%
      with({
        if(tableFormat == 'long')      SpreadsAndTotalsLong(.)
        else if(tableFormat == 'wide')      SpreadsAndTotalsWide(.)
        else if(tableFormat == 'subtables') .
        else if(tableFormat == 'clean') expandListColumns(.)
        else stop("Undefined value for tableFormat, options are 'mainlines','long','wide', and 'subtables'")
      }) %>%
      as.data.frame()
  }


