# ---------------------------------------------------------------------------
# Credential persistence – save/load JWT token + email to a local dotfile
# ---------------------------------------------------------------------------

#' @noRd
credentials_path <- function() {
  file.path(Sys.getenv("HOME"), ".gptRBridge_credentials")
}

#' Save login credentials after a successful login.
#'
#' @param email User email.
#' @param password User password.
save_credentials <- function(email, password) {
  data <- list(email = email, password = password)
  tryCatch(
    writeLines(jsonlite::toJSON(data, auto_unbox = TRUE), credentials_path()),
    error = function(e) NULL
  )
}

#' Load saved credentials.
#'
#' @return A list with `email` and `password`, or NULL if none saved.
load_credentials <- function() {
  path <- credentials_path()
  if (!file.exists(path)) return(NULL)
  tryCatch({
    data <- jsonlite::fromJSON(readLines(path, warn = FALSE))
    if (!is.null(data$email) && !is.null(data$password)) data else NULL
  }, error = function(e) NULL)
}

#' Delete saved credentials.
clear_credentials <- function() {
  path <- credentials_path()
  if (file.exists(path)) file.remove(path)
}
