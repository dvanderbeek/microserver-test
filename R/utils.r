`%||%` <- function(x, y) if (is.null(x)) y else x

from_json <- function(obj) {
  simplify_homogeneous_lists(jsonlite::fromJSON(obj, simplifyVector = FALSE))
}

has_names <- function(obj) {
  !is.null(names(obj)) && !is.null(Find(function(s) !is.na(s) && (s != ""), names(obj)))
}

enlist_if_named <- function(obj) {
  if(is.atomic(obj) && has_names(obj)) as.list(obj) else obj
}

recursively_enlist_if_named <- function(obj) {
  if (is.atomic(obj) || length(obj) == 0) enlist_if_named(obj)
  else {
    if (is.data.frame(obj)) {
      as.data.frame(lapply(obj, recursively_enlist_if_named))
    } else lapply(obj, recursively_enlist_if_named)
  }
}

to_json <- function(obj) {
  obj2 <- recursively_enlist_if_named(obj)
  as.character(jsonlite::toJSON(obj2, auto_unbox = TRUE))
}

#' Fix jsonlite's JSON simplification.
#'
#' @param object any R object derived from \code{\link[jsonlite]{fromJSON}}.
#' @param simple_check logical. This is needed to modify behavior for recursive function call.
#' @return the same object, with any list components where each element is
#'   an atomic vector of length 1 or NULL coerced to a single atomic vector.
#' @note See https://github.com/jeroenooms/jsonlite/issues/66 for more details.
#' @examples
#' \dontrun{
#'   simplify_homogeneous_lists(jsonlite::fromJSON(
#'    '{ "numeric": [1,2], "list": [1, "a"] }', simplifyVector = FALSE))
#'   # A list with atomic numeric vector in the "numeric" key and
#'   # a list in the "list" key.
#'   # list(numeric = c(1,2), list = list(1, "a"))
#' }
simplify_homogeneous_lists <- function(object, simple_check = TRUE) {
  if (isTRUE(simple_check) && is_simple_list(object)) { return(try_simplify(object)) }
  if (is.list(object)) {
    if (all(vapply(object, terminal, logical(1)))) {
      type <- common_type(object)
      if (identical(type, "NULL")) { object }
      else if (is.na(type)) { object }
      else {
        vapply(object, tricky_identity, vector(type, 1), type)
      }
    } else {
      lapply(object, simplify_homogeneous_lists, simple_check = FALSE)
    }
  } else { object }
}

try_simplify <- function(lst) {
  if (any(vapply(lst, is.null, logical(1)))) { denull(lst) } else { simplify_homogeneous_lists(lst, simple_check = FALSE) }
}

is_simple_list <- function(lst) {
  is.list(lst) && all(vapply(lst, Negate(is.list), logical(1))) && all(vapply(lst, length, numeric(1)) <= 1)
}

denull <- function (lst) {
  Map(function(x) { if (is.null(x)) NA else x }, lst)
}

tricky_identity <- function(obj, type) {
  if (is.null(obj)) { as(NA, type) } else { as(obj, type) }
}

terminal <- function(x) {
  is.null(x) || (is.atomic(x) && length(x) == 1)
}

common_type <- function(x) {
  types <- vapply(Filter(Negate(is.null), x), class, character(1))
  if (length(types) == 0) { "NULL" }
  else if (length(unique(types)) == 1) { types[1] }
  else { NA }
}

packagefile <- function(file, ..., read = FALSE) {
  file <- system.file(file, ..., package = "microserver")
  if (isTRUE(read)) {
    paste(collapse = "\n", readLines(file))
  } else {
    file
  }
}
