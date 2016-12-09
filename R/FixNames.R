#' Fix up names to be shorter
#'
#' @param dt a data.table with pinnacle.API standard names
#' @param lastx last x names to use as part of an identifier
#'
#' @return same data.frame with names fixed to length x indicators
#' @export
FixNames <- function(dt, lastx = 2) {
  dt %>%
    setNames(
      sapply(strsplit(names(dt),'\\.'),
             function(x) {
               out <- x[length(x) - (min(lastx, length(x)) - 1):0]
               paste(out, collapse = '.')
             })
    )
}
