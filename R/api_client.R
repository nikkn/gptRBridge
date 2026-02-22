# ---------------------------------------------------------------------------
# API client – HTTP calls to the GPT-R-Bridge backend
# ---------------------------------------------------------------------------

#' @noRd
get_base_url <- function() {
  url <- getOption("gptRBridge.base_url", "https://2ydbe75mmb.execute-api.eu-north-1.amazonaws.com")
  sub("/$", "", url)
}

#' Log in and return the JWT access token.
#'
#' @param email User email.
#' @param password User password.
#' @return Character string: the JWT token, or NULL on failure.
api_login <- function(email, password) {
  url <- paste0(get_base_url(), "/auth/login")
  # The /auth/login endpoint expects OAuth2 form data (username + password).
  res <- httr::POST(
    url,
    body = list(username = email, password = password),
    encode = "form"
  )
  if (httr::status_code(res) != 200) {
    msg <- tryCatch(
      httr::content(res, as = "parsed")$detail,
      error = function(e) "Login failed"
    )
    return(list(ok = FALSE, error = msg))
  }
  body <- httr::content(res, as = "parsed")
  list(ok = TRUE, token = body$access_token)
}

#' Register a new account.
#'
#' @param email User email.
#' @param password User password.
#' @return List with `ok` (logical) and `message` or `error`.
api_register <- function(email, password) {
  url <- paste0(get_base_url(), "/auth/register")
  res <- httr::POST(
    url,
    body = jsonlite::toJSON(
      list(email = email, password = password),
      auto_unbox = TRUE
    ),
    httr::content_type_json()
  )
  if (httr::status_code(res) == 201) {
    return(list(ok = TRUE, message = "Account created. You can now log in."))
  }
  msg <- tryCatch(
    httr::content(res, as = "parsed")$detail,
    error = function(e) "Registration failed"
  )
  list(ok = FALSE, error = msg)
}

#' Send chat messages to the AI backend.
#'
#' @param messages List of lists, each with `role` and `content`.
#' @param token JWT bearer token.
#' @param system_prompt Optional system prompt override.
#' @return List with `ok`, and either `reply` + `tokens_used` or `error`.
api_chat <- function(messages, token, system_prompt = NULL) {
  url <- paste0(get_base_url(), "/ai/chat")
  payload <- list(messages = messages)
  if (!is.null(system_prompt)) {
    payload$system_prompt <- system_prompt
  }
  res <- httr::POST(
    url,
    body = jsonlite::toJSON(payload, auto_unbox = TRUE),
    httr::content_type_json(),
    httr::add_headers(Authorization = paste("Bearer", token))
  )
  if (httr::status_code(res) == 200) {
    body <- httr::content(res, as = "parsed")
    return(list(ok = TRUE, reply = body$reply, tokens_used = body$tokens_used))
  }
  msg <- tryCatch(
    httr::content(res, as = "parsed")$detail,
    error = function(e) paste("Request failed (HTTP", httr::status_code(res), ")")
  )
  list(ok = FALSE, error = msg)
}

#' Create a Stripe checkout session and return the URL.
#'
#' @param token JWT bearer token.
#' @return List with `ok` and either `checkout_url` or `error`.
api_checkout <- function(token) {
  url <- paste0(get_base_url(), "/ai/checkout")
  res <- httr::POST(
    url,
    httr::content_type_json(),
    httr::add_headers(Authorization = paste("Bearer", token))
  )
  if (httr::status_code(res) == 200) {
    body <- httr::content(res, as = "parsed")
    return(list(ok = TRUE, checkout_url = body$checkout_url))
  }
  msg <- tryCatch(
    httr::content(res, as = "parsed")$detail,
    error = function(e) "Could not create checkout session"
  )
  list(ok = FALSE, error = msg)
}
