# ---------------------------------------------------------------------------
# Code utilities – extract and insert R code from AI responses
# ---------------------------------------------------------------------------

#' @noRd
#' Extract all R code blocks from a markdown-formatted AI reply.
#'
#' Looks for fenced code blocks tagged as ```r or ```R.
#' Falls back to un-tagged ``` blocks if no R-specific ones are found.
#'
#' @param text Character string (the AI reply).
#' @return Character vector of code strings (one per block), or character(0).
extract_r_code <- function(text) {
  # Try ```r blocks first ((?s) lets . match newlines)
  pattern <- "(?s)```[rR]\\s*\\n(.*?)```"
  m <- gregexpr(pattern, text, perl = TRUE)
  blocks <- regmatches(text, m)[[1]]
  if (length(blocks) > 0) {
    code <- sub("(?s)^```[rR]\\s*\\n", "", blocks, perl = TRUE)
    code <- sub("\\n?```$", "", code)
    return(code)
  }
  # Fallback: any fenced block
  pattern_generic <- "(?s)```\\s*\\n(.*?)```"
  m2 <- gregexpr(pattern_generic, text, perl = TRUE)
  blocks2 <- regmatches(text, m2)[[1]]
  if (length(blocks2) > 0) {
    code2 <- sub("(?s)^```\\s*\\n", "", blocks2, perl = TRUE)
    code2 <- sub("\\n?```$", "", code2)
    return(code2)
  }
  character(0)
}
