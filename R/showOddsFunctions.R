#' Sets the determined depth as a data.frame, and evades R's list-dropping rules
#'
#' @param x a list
#' @param depth numeric value of the number of sublist
#'
#' @return a tree with the defined level as a dataframe
#'
#' @importFrom  plyr rbind.fill
fixPeriods <- function(x,depth=5) {
  if(depth==0) {
    plyr::rbind.fill(
      if(length(x)>1) {
        lapply(x, data.frame)
      } else {
        list(data.frame(x))
      })
  } else {
    lapply(x, function(element) {
      if('list' %in% class(element)) fixPeriods(element,depth-1) else element
    })
  }
}




#'Combines the list at given depth with the factors associated with that depth
#'
#' @param x A list
#' @param depth Number of levels of sublists
#'
#' @return a tree with the factors at the defined level combined with a df
#'
combineFactors <- function(x,depth=4) {
  if(depth==0) {
    Reduce(cbind,x)
  } else {
    lapply(x, function(element) {
      if('list' %in% class(element)) combineFactors(element,depth-1) else element
    })
  }
  
  
}


