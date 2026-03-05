extract_r_code <- function(text) {
  pattern <- "(?s)```[rR]\\s*\\n(.*?)```"
  m <- gregexpr(pattern, text, perl = TRUE)
  blocks <- regmatches(text, m)[[1]]
  if (length(blocks) > 0) {
    code <- sub("(?s)^```[rR]\\s*\\n", "", blocks, perl = TRUE)
    code <- sub("\\n?```$", "", code)
    return(code)
  }
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
