#' Sets the determined depth as a data.frame, and evades R's list-dropping rules
#'
#' @param x a list
#' @param depth numeric value of the number of sublist
#' @param flag whether to start with combining factors or binding rows
#' @return a tree with the defined level as a dataframe
#' @export
JSONtoDF <- function(x,depth=5,flag=TRUE) {
    if(depth==0) {
      dplyr::bind_rows(if(length(x)>1) lapply(x, data.frame) else list(data.frame(x)))
    } else if(flag) {
      cbindNames(lapply(x, function(element) if('list' %in% class(element)) JSONtoDF(element,depth-1,flag = !flag) else element))
    } else {
      dplyr::bind_rows(lapply(x, function(element) if('list' %in% class(element)) JSONtoDF(element,depth-1,flag = !flag) else element))
    }
}


#' Combines elements of an object, keeping names
#'
#' @param x takes a list of elements with names
#'
#' @return data.frame containing combined names
#' @export
cbindNames <- function(x) {
  namesList <- sapply(names(x), function(elename) {
    if(length(x[[elename]]) != 0) {
           if('list' %in% typeof(x[elename][[1]])) names(x[elename][[1]]) 
           else elename} else NULL})
  
  result <- Reduce(function(a,b) if(length(a) !=0 & length(b)!=0) data.frame(a,b) else c(a,b), x)
  names(result) <- unlist(namesList)
  data.frame(result)
}



