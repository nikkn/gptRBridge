credentials_path <- function() {
  file.path(Sys.getenv("HOME"), ".gptRBridge_credentials")
}

save_credentials <- function(token) {
  data <- list(token = token)
  tryCatch(
    writeLines(jsonlite::toJSON(data, auto_unbox = TRUE), credentials_path()),
    error = function(e) NULL
  )
}

load_credentials <- function() {
  path <- credentials_path()
  if (!file.exists(path)) return(NULL)
  tryCatch({
    data <- jsonlite::fromJSON(readLines(path, warn = FALSE))
    if (!is.null(data$token)) data else NULL
  }, error = function(e) NULL)
}

clear_credentials <- function() {
  path <- credentials_path()
  if (file.exists(path)) file.remove(path)
}
