get_base_url <- function() {
  url <- getOption("gptRBridge.base_url", "https://2ydbe75mmb.execute-api.eu-north-1.amazonaws.com")
  sub("/$", "", url)
}

api_login <- function(email, password) {
  url <- paste0(get_base_url(), "/auth/login")
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
    body <- httr::content(res, as = "parsed")
    return(list(
      ok        = TRUE,
      message   = body$message,
      setup_url = body$setup_url
    ))
  }
  msg <- tryCatch(
    httr::content(res, as = "parsed")$detail,
    error = function(e) "Registration failed"
  )
  list(ok = FALSE, error = msg)
}

api_setup_card <- function(token) {
  url <- paste0(get_base_url(), "/auth/setup-card")
  res <- httr::POST(
    url,
    httr::content_type_json(),
    httr::add_headers(Authorization = paste("Bearer", token))
  )
  if (httr::status_code(res) == 200) {
    body <- httr::content(res, as = "parsed")
    return(list(ok = TRUE, setup_url = body$setup_url))
  }
  msg <- tryCatch(
    httr::content(res, as = "parsed")$detail,
    error = function(e) "Could not create card setup session"
  )
  list(ok = FALSE, error = msg)
}

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
