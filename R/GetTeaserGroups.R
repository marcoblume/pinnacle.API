GetTeaserGroups <-
  function(oddsformat){
    
    CheckTermsAndConditions()
    
    
    r <- sprintf('%s/v1/teaser/groups', .PinnacleAPI$url) %>%
      GET(add_headers(Authorization= authorization(),
                      "Content-Type" = "application/json"),
          query = list(oddsFormat = oddsformat)) %>%
      content(type="text") 
    
    
    # If no rows are returned, return empty data.frame
    if(identical(r, '')) return(data.frame())
    
    r %>%
      jsonlite::fromJSON(flatten = TRUE) %>%
      as.data.table %>%
      with({
        if(all(sapply(.,is.atomic))) .
        else expandListColumns(.)
      }) %>%
      as.data.frame()
  }