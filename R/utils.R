# CRAN FIXES
#' @importFrom purrr map_if
#' @import magrittr
#' @importFrom stats setNames
if(getRversion() >= "2.15.1")  utils::globalVariables(c("."))
grp <- NULL
sports.id <- NULL

# Simplifies each list column to be wide
simplify_all <- function(x) {
  # Define to eliminate CRAN Note
  altLineId <- nullcol <- NULL
  
  # Remove Mainlines
  mainlines <- 
    lapply(x, function(y) {
      if(is.null(y)) data.frame(nullcol = NA) 
      else if(!is.null(y[['altLineId']])) y[is.na(y[['altLineId']]),] 
      else y
    })
  
  max_mainlines_returned <- max(sapply(mainlines, NROW))
  
  if(max_mainlines_returned == 1) {
    alternates <- 
      lapply(x, function(y) {
        if(!is.null(y) && !is.null(y[['altLineId']])) as.list(unlist_special(y[!is.na(y[['altLineId']]),]))
      })
    out <- rbindlist(Map(c, mainlines, alternates), fill = TRUE)
    suppressWarnings(out[, nullcol := NULL])
    # altLineId is always null by design
    suppressWarnings(out[, altLineId := NULL])
    out
  } else {
    # several lines per row. Specials
    # no altLineId will be present
    suppressWarnings(
      rbindlist(
        lapply(mainlines, function(x) {
          if(length(x) > 0) as.list(unlist_special(x))
          else list(id = NA, 
                    lineId = NA, 
                    price = NA,
                    handicap = NA)
          }), 
        fill = TRUE
      )
    )
  }
}

# Does unlist, but with a better naming convention
unlist_special <- function(x) {
  structure(
    unlist(x,use.names = FALSE), 
    .Names = 
      paste(
        rep(names(x), each = NROW(x)), 
        rep(1:NROW(x), length(x)), sep = '_')
    )
}

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

# Raise formatted Pinnacle API errors for an httr::response object.
CheckForAPIErrors <- function(response) {
  code <- httr::status_code(response)
  # Ignore HTTP status OK (200) objects.
  if (code != 200) {
    if (httr::http_type(response) == "application/json") {
      # Translate JSON errors, if provided.
      response <- response %>%
        httr::content(type = "text", encoding = "UTF-8") %>%
        jsonlite::fromJSON()
      stop(paste0(response$message,
                  ifelse(endsWith(response$message, "."), "", "."),
                  " (code: ", response$code, ")"))
    } else {
      # Give approximate errors when the error does not return JSON.
      switch(as.character(code),
             "400" = stop("Invalid request parameters."),
             "401" = stop("Invalid or missing login credentials."),
             "403" = stop("Account is inactive or lacks API access."),
             "500" = stop("Internal API server error."),
             stop("API request returned HTTP code ", code))
    }
  }
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
  #browser()
  dt %>%
    .[, c(purrr::discard(.SD, is.list),do.call(c,lapply(purrr::keep(.SD, is.list), simplify_all)))]
    # map_if(is.list, lapply, as.list) %>%
    # #as.data.table %>%
    # RemoveNulls %>%
    # map_if(is.list, rbindlist, fill = TRUE) %>%
    # as.data.table
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
