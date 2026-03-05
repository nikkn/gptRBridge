build_server <- function() {
  function(input, output, session) {

    rv <- shiny::reactiveValues(
      token           = NULL,
      chat_history    = list(),
      thinking        = FALSE,
      trial_exhausted = FALSE,
      card_required   = FALSE
    )

    output$is_logged_in <- shiny::reactive({ !is.null(rv$token) })
    shiny::outputOptions(output, "is_logged_in", suspendWhenHidden = FALSE)

    shiny::observe({
      creds <- load_credentials()
      if (!is.null(creds) && !is.null(creds$token)) {
        rv$token <- creds$token
        shiny::showNotification("Logged in automatically.", type = "message",
                                duration = 3)
      }
    }) |> shiny::bindEvent(TRUE)

    shiny::observeEvent(input$btn_login, {
      result <- api_login(input$email, input$password)
      if (result$ok) {
        rv$token <- result$token
        save_credentials(result$token)
        output$login_status <- shiny::renderUI(NULL)
      } else {
        output$login_status <- shiny::renderUI(
          shiny::tags$div(style = "color:red;", result$error)
        )
      }
    })

    shiny::observeEvent(input$btn_register, {
      result <- api_register(input$email, input$password)
      if (result$ok) {
        output$login_status <- shiny::renderUI(
          shiny::tagList(
            shiny::tags$div(style = "color:green; font-size:13px;", result$message),
            if (!is.null(result$setup_url))
              shiny::tags$p(
                style = "margin-top:10px;",
                shiny::tags$a(
                  href   = result$setup_url,
                  target = "_blank",
                  style  = "color:#3498db; font-weight:600; font-size:13px;",
                  "Add your card to activate your trial"
                )
              )
          )
        )
        if (!is.null(result$setup_url)) {
          try(utils::browseURL(result$setup_url), silent = TRUE)
        }
      } else {
        output$login_status <- shiny::renderUI(
          shiny::tags$div(style = "color:red;", result$error)
        )
      }
    })

    shiny::observeEvent(input$btn_logout, {
      rv$token           <- NULL
      rv$chat_history    <- list()
      rv$thinking        <- FALSE
      rv$trial_exhausted <- FALSE
      clear_credentials()
    })

    shiny::observeEvent(input$btn_send, {
      msg <- trimws(input$user_msg)
      if (nchar(msg) == 0) return()

      if (isTRUE(rv$trial_exhausted)) {
        shiny::showNotification(
          "Your free trial has ended. Please subscribe to continue.",
          type = "warning", duration = 4
        )
        return()
      }

      if (isTRUE(rv$thinking)) return()

      rv$chat_history <- c(rv$chat_history, list(list(role = "user", content = msg)))
      shiny::updateTextAreaInput(session, "user_msg", value = "")
      rv$thinking <- TRUE

      history_window <- rv$chat_history
      if (length(history_window) > 10) {
        history_window <- tail(history_window, 10)
      }

      session$sendCustomMessage("do_chat", list(
        token    = rv$token,
        messages = history_window,
        base_url = get_base_url()
      ))
    })

    shiny::observeEvent(input$chat_response, {
      resp <- input$chat_response
      rv$thinking <- FALSE

      if (isTRUE(resp$ok)) {
        rv$chat_history <- c(
          rv$chat_history,
          list(list(role = "assistant", content = resp$reply))
        )
      } else if (identical(resp$detail, "trial_exhausted")) {
        rv$trial_exhausted <- TRUE
      } else if (identical(resp$detail, "card_required")) {
        rv$card_required <- TRUE
      } else {
        detail <- if (!is.null(resp$detail)) resp$detail else "Request failed"
        shiny::showNotification(detail, type = "error", duration = 5)
      }
    })

    shiny::observeEvent(input$btn_subscribe, {
      result <- api_checkout(rv$token)
      if (result$ok) {
        utils::browseURL(result$checkout_url)
      } else {
        shiny::showNotification(result$error, type = "error", duration = 5)
      }
    })

    shiny::observeEvent(input$btn_add_card, {
      result <- api_setup_card(rv$token)
      if (result$ok) {
        utils::browseURL(result$setup_url)
      } else {
        shiny::showNotification(result$error, type = "error", duration = 5)
      }
    })

    shiny::observe({
      shiny::invalidateLater(500, session)

      ipc_output <- Sys.getenv("GPTRBRIDGE_IPC_OUTPUT")
      if (nchar(ipc_output) == 0) return()
      if (!file.exists(ipc_output)) return()

      text <- tryCatch({
        lines <- readLines(ipc_output, warn = FALSE)
        tryCatch(file.remove(ipc_output), error = function(e) NULL)
        trimws(paste(lines, collapse = "\n"))
      }, error = function(e) "")
      if (nchar(text) == 0) return()

      auto_insert <- shiny::isolate(input$chk_auto_insert)
      if (!isTRUE(auto_insert)) return()

      current <- shiny::isolate(input$user_msg)
      separator <- if (nchar(trimws(current)) > 0) "\n---\n" else ""
      new_val <- paste0(current, separator, text)
      shiny::updateTextAreaInput(session, "user_msg", value = new_val)
    })

    shiny::observeEvent(input$insert_code_click, {
      code <- input$insert_code_click
      ipc_file <- Sys.getenv("GPTRBRIDGE_IPC")
      if (nchar(ipc_file) > 0 && nchar(trimws(code)) > 0) {
        writeLines(code, ipc_file)
        shiny::showNotification("Code inserted.", type = "message", duration = 2)
      }
    })

    output$chat_messages <- shiny::renderUI({
      history       <- rv$chat_history
      thinking      <- rv$thinking
      exhausted     <- rv$trial_exhausted
      card_required <- rv$card_required

      bubbles <- lapply(history, function(m) {
        css_class <- if (m$role == "user") "chat-bubble user" else "chat-bubble assistant"
        rendered  <- render_markdown_simple(m$content)
        shiny::tags$div(class = css_class, shiny::HTML(rendered))
      })

      if (thinking) {
        bubbles <- c(bubbles, list(
          shiny::tags$div(
            class = "chat-bubble assistant thinking-bubble",
            shiny::HTML(
              '<span class="thinking-dots">
                <span></span><span></span><span></span>
              </span>'
            )
          )
        ))
      }

      if (card_required) {
        bubbles <- c(bubbles, list(
          shiny::tags$div(
            class = "trial-exhausted-banner",
            shiny::tags$p(
              "Card needed for fraud protection only \u2014 not billing.",
              shiny::tags$br(),
              "Add your card to unlock 50 free trial calls."
            ),
            shiny::actionButton("btn_add_card", "Add card \u2192",
                                class = "btn-subscribe-inline")
          )
        ))
      }

      if (exhausted) {
        bubbles <- c(bubbles, list(
          shiny::tags$div(
            class = "trial-exhausted-banner",
            shiny::tags$strong("Your free trial has ended."),
            shiny::tags$strong("Subscribe to unlock full access."),
            shiny::actionButton("btn_subscribe", "Subscribe now \u2192",
                                class = "btn-subscribe-inline")
          )
        ))
      }

      if (length(bubbles) == 0) {
        return(shiny::tags$div(
          style = "color:#999; text-align:center; margin-top:40px; font-size:13px;",
          "Start a conversation \u2014 ask about your data, a model, or a plot."
        ))
      }
      shiny::tagList(bubbles)
    })

    shiny::observeEvent(input$done, {
      shiny::stopApp()
    })
  }
}


render_markdown_simple <- function(text) {
  math_ph      <- character(0)
  math_content <- character(0)
  math_matches <- regmatches(text, gregexpr("(?s)\\\\\\[.+?\\\\\\]", text, perl = TRUE))[[1]]
  if (length(math_matches) > 0) {
    for (i in seq_along(math_matches)) {
      ph <- paste0("\x01MATHDISP", i, "\x01")
      math_ph[i]      <- ph
      math_content[i] <- math_matches[i]
      text <- sub(math_matches[i], ph, text, fixed = TRUE)
    }
  }

  text <- gsub("&", "&amp;", text, fixed = TRUE)
  text <- gsub("<", "&lt;", text, fixed = TRUE)
  text <- gsub(">", "&gt;", text, fixed = TRUE)

  pattern <- "(?s)```[a-zA-Z]*\\s*\\n(.*?)\\n```"
  m <- gregexpr(pattern, text, perl = TRUE)
  blocks <- regmatches(text, m)[[1]]
  placeholders <- character(0)
  if (length(blocks) > 0) {
    for (i in seq_along(blocks)) {
      code_content <- sub("(?s)^```[a-zA-Z]*\\s*\\n", "", blocks[i], perl = TRUE)
      code_content <- sub("\\n?```$", "", code_content)
      ph <- paste0("\x01CODEBLOCK", i, "\x01")
      placeholders[i] <- ph
      text <- sub(blocks[i], ph, text, fixed = TRUE)
    }
  }

  text <- gsub("`([^`]+)`", "<code>\\1</code>", text, perl = TRUE)
  text <- gsub("\\*\\*(.+?)\\*\\*", "<strong>\\1</strong>", text, perl = TRUE)
  text <- gsub("\\*(.+?)\\*", "<em>\\1</em>", text, perl = TRUE)
  text <- gsub("\n", "<br/>", text, fixed = TRUE)

  if (length(math_ph) > 0) {
    for (i in seq_along(math_ph)) {
      text <- sub(math_ph[i],
                  paste0('<span style="display:block;text-align:center;margin:8px 0">',
                         math_content[i], '</span>'),
                  text, fixed = TRUE)
    }
  }

  if (length(blocks) > 0) {
    for (i in seq_along(blocks)) {
      code_content <- sub("(?s)^```[a-zA-Z]*\\s*\\n", "", blocks[i], perl = TRUE)
      code_content <- sub("\\n?```$", "", code_content)
      html_block <- paste0(
        "<div class=\"code-block-wrap\">",
        "<button class=\"code-insert-btn\" type=\"button\">Insert</button>",
        "<pre><code>", code_content, "</code></pre></div>"
      )
      text <- sub(placeholders[i], html_block, text, fixed = TRUE)
    }
  }

  text
}


start_app <- function(port = 3838) {
  app <- shiny::shinyApp(ui = build_ui(), server = build_server())
  shiny::runApp(app, port = port, host = "127.0.0.1", launch.browser = FALSE)
}


.poll_ipc <- function(ipc_code,
                      stop_time = Sys.time() + 8 * 3600,
                      interval  = 0.5) {
  if (Sys.time() > stop_time) return(invisible(NULL))

  if (rstudioapi::isAvailable()) {
    if (file.exists(ipc_code)) {
      code <- paste(readLines(ipc_code, warn = FALSE), collapse = "\n")
      file.remove(ipc_code)
      if (nchar(trimws(code)) > 0) {
        rstudioapi::insertText(text = paste0(code, "\n"))
      }
    }
  }

  later::later(
    function() .poll_ipc(ipc_code, stop_time, interval),
    delay = interval
  )
}


#' Launch the gptRBridge addin.
#'
#' @return Invisibly returns the port number the Shiny app is listening on.
#' @export
#' @examples
#' \dontrun{
#' launch_addin()
#' }
launch_addin <- function() {
  port       <- sample(10000:60000, 1)
  ipc_code   <- normalizePath(tempfile("gptRBridge_code_"),   winslash = "/", mustWork = FALSE)
  ipc_output <- normalizePath(tempfile("gptRBridge_output_"), winslash = "/", mustWork = FALSE)

  script <- normalizePath(tempfile("gptRBridge_", fileext = ".R"),
                          winslash = "/", mustWork = FALSE)
  writeLines(
    sprintf(
      paste0(
        'Sys.setenv(GPTRBRIDGE_IPC        = "%s")\n',
        'Sys.setenv(GPTRBRIDGE_IPC_OUTPUT = "%s")\n',
        'library(gptRBridge)\n',
        'gptRBridge:::start_app(port = %dL)'
      ),
      ipc_code, ipc_output, port
    ),
    script
  )

  rstudioapi::jobRunScript(
    path       = script,
    name       = "GPT-R-Bridge",
    workingDir = getwd()
  )

  Sys.sleep(2)
  rstudioapi::viewer(sprintf("http://127.0.0.1:%d", port))

  .poll_ipc(ipc_code)

  addTaskCallback(function(expr, value, ok, visible) {
    tryCatch({
      if (ok && visible) {
        out <- paste(utils::capture.output(print(value)), collapse = "\n")
        if (nchar(trimws(out)) > 0 && nchar(out) <= 5000) {
          writeLines(out, ipc_output)
        }
      }
    }, error = function(e) NULL)
    TRUE
  }, name = "gptRBridge_capture")

  prev_error <- getOption("error")
  options(error = function() {
    err_msg <- geterrmessage()
    if (nchar(trimws(err_msg)) > 0) {
      writeLines(paste0("[Error]\n", err_msg), ipc_output)
    }
    if (is.function(prev_error)) prev_error()
  })

  invisible(port)
}
