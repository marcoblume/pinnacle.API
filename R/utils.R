# CRAN FIXES
#' @importFrom purrr map_if
#' @import magrittr
#' @importFrom stats setNames
if(getRversion() >= "2.15.1")  utils::globalVariables(c("."))
grp <- NULL
sports.id <- NULL
simplify_all <- NULL

# expand list columns, only works if we have corresponding data
# for example, two tables of alt-lines will give misleading data
expandListColumns <- function(dt) {
  #require(data.table)
  
  x <- 
    try( 
      dt[,as.data.table(unlist(.SD, recursive = FALSE)), 
         by = mget(names(dt)[sapply(dt,is.atomic)])],
      silent = TRUE
    )
  
  # Method # 2, directly make everything a data.frame
  if('try-error' %in% class(x)) {
    x <- try(dt[,rbindlist(apply(.SD,1, data.frame),fill = TRUE)], silent = TRUE)
  } else x
  
  # method # 3 coerce all NULLs to properly formatted, then apply data.frame
  if('try-error' %in% class(x)) {
    x <- 
      dt %>%
      RemoveNulls() %>%
      map_if(is.list, lapply, data.frame) %>%
      as.data.table %>%
      apply(1, data.frame) %>%
      rbindlist(fill = TRUE) %>%
      as.data.table
  } else x
  
}

APIcall <- function(endpoint, query = NULL) {
  sprintf('%s/%s', .PinnacleAPI$url, endpoint) %>%
    modify_url(query = query) %>%
    httr::GET(add_headers(Authorization= authorization(),
                        "Content-Type" = "application/json")) %>%
    content(type="text")
}

# Remove Nulls from lists:
RemoveNulls <- function(dt) {
  # if(!is.data.table(dt)) stop('Function only defined for data.table')
  dt %>%
    map_if(is.list, function(y) {
      tmp <- names(rbindlist(y, fill = TRUE))
      tmp <- setNames(replicate(length(tmp),NA,simplify = FALSE), tmp)
      map_if(y, function(x) length(x) == 0, function(x) tmp)
    })
}




# Takes only the first element from each name in each sublist
SpreadsAndTotalsMainlines <- function(dt) {
  RemoveNulls(dt) %>%
    map_if(is.list, lapply, data.frame) %>%
    map_if(is.list, lapply, first) %>%
    map_if(is.list, rbindlist, fill = TRUE) %>%
    as.data.table
}

# Puts data into wide format (not recommended)
SpreadsAndTotalsWide <- function(dt) {
  dt %>%
    map_if(is.list, simplify_all) %>%
    map_if(is.list, lapply, as.list) %>%
    #as.data.table %>%
    RemoveNulls %>%
    map_if(is.list, rbindlist, fill = TRUE) %>%
    as.data.table
}

# Best way for interacting with data
SpreadsAndTotalsLong <- function(dt) {
  dt %>%
    melt.data.table(measure.vars = names(.)[sapply(.,is.list)],variable.name = 'field') %>%
    RemoveNulls %>%
    as.data.table %>%
    with({
      if(all(sapply(.,is.atomic))) .
      else expandListColumns(.)
    })
}

# Shows Selections in pretty column format
displaySelections <- function(x,ncolumn=getOption('width') %/% (max(nchar(x)) + 1) - 1) {
  
 
  nrows = length(x) %/% ncolumn + 1
  
  # Pad all values to the same length
  tmp = padToSameLength(x)
  #tmp[1] = paste(" ",tmp[1])
  tmp = data.table(x = tmp)
  tmp[,grp := (1:.N)%%(nrows - 1)]
  tmp <- tmp[,.(list(x)), by = grp]
 
  cat(paste(sapply(tmp$V1, paste, collapse = ''),collapse = '\n'))
  cat("\n")
}

padToSameLength <- function(x,side = 'left') {
  tmp = as.character(x)
  m = max(nchar(tmp)) + 1
  lens = vapply(tmp, nchar, 1, USE.NAMES = FALSE)
  padding = vapply(m - lens, function(x) paste(rep(' ',x),collapse = ''),'')
  if(side == 'left') {
    tmp = paste0(tmp,padding)
  } else {
    tmp = paste0(padding,tmp)
  }
  tmp
}

# Offer user a choice of sports
ViewSports <- 
  function(force = TRUE,
           showEventCount = TRUE,
           showEspecials = FALSE,
           showLspecials = FALSE) {
    with(GetSports(force = TRUE),{
      cat(sprintf('SportId - Sport (# %s):\n',
                  paste0(if(showEventCount) 'events',
                         if(showEspecials) 'event specials',
                         if(showLspecials) 'league specials', collapse = '|')))
      displaySelections(sprintf('%s - %s (%s)',
                                padToSameLength(id), 
                                padToSameLength(name), 
                                trimws(paste0(if(showEventCount) eventCount,
                                       if(showEspecials) eventSpecialsCount,
                                       if(showLspecials) leagueSpecialsCount)))) # Ugly #, leagueSpecialsCount, eventSpecialsCount))
    })
  }

# Offer user a choice of leagues
ViewLeagues <- 
  function(sportid, 
           showEventCount = TRUE,
           showEspecials = FALSE,
           showLspecials = FALSE,
           force = TRUE) {
    leagues <- GetLeaguesByID(sportid, force = TRUE)
    leagues <- leagues[order(leagues$leagues.name),]
    with(leagues, {
      cat(sprintf('LeagueId - League (# %s):\n',
                  paste0(if(showEventCount) 'events',
                         if(showEspecials) 'event specials',
                         if(showLspecials) 'league specials', collapse = '|')))
      displaySelections(sprintf('%s - %s (%s)',
                                padToSameLength(leagues.id), 
                                padToSameLength(trimws(leagues.name)), 
                                trimws(paste0(if(showEventCount) leagues.eventCount,
                                              if(showEspecials) leagues.eventSpecialsCount,
                                              if(showLspecials) leagues.leagueSpecialsCount,sep = '|')))) # Ugly #, leagueSpecialsCount, eventSpecialsCount))
    })
  }
