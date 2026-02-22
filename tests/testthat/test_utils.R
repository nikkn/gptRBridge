# Tests for pure utility functions (no network, no RStudio required).

# Access internal functions via :::
rms  <- gptRBridge:::render_markdown_simple
erc  <- gptRBridge:::extract_r_code

# ---------------------------------------------------------------------------
# render_markdown_simple
# ---------------------------------------------------------------------------

test_that("render_markdown_simple escapes HTML special characters", {
  out <- rms("a < b & c > d")
  expect_true(grepl("&lt;", out, fixed = TRUE))
  expect_true(grepl("&amp;", out, fixed = TRUE))
  expect_true(grepl("&gt;", out, fixed = TRUE))
})

test_that("render_markdown_simple converts newlines to <br/>", {
  out <- rms("line1\nline2")
  expect_true(grepl("<br/>", out, fixed = TRUE))
})

test_that("render_markdown_simple wraps code blocks in <pre><code>", {
  out <- rms("```r\nx <- 1\n```")
  expect_true(grepl("<pre><code>", out, fixed = TRUE))
  expect_true(grepl("x &lt;- 1", out, fixed = TRUE)) 
})

test_that("render_markdown_simple adds Insert button to code blocks", {
  out <- rms("```r\nx <- 1\n```")
  expect_true(grepl("code-insert-btn", out, fixed = TRUE))
})

test_that("render_markdown_simple handles inline code", {
  out <- rms("use `mean()` here")
  expect_true(grepl("<code>mean()</code>", out, fixed = TRUE))
})

# ---------------------------------------------------------------------------
# extract_r_code
# ---------------------------------------------------------------------------

test_that("extract_r_code finds ```r blocks", {
  text  <- "Hello\n```r\nx <- 1\n```\nbye"
  code  <- erc(text)
  expect_length(code, 1L)
  expect_equal(trimws(code[[1]]), "x <- 1")
})

test_that("extract_r_code finds ```R blocks (uppercase)", {
  text  <- "```R\ny <- 2\n```"
  code  <- erc(text)
  expect_length(code, 1L)
  expect_equal(trimws(code[[1]]), "y <- 2")
})

test_that("extract_r_code returns character(0) when no blocks present", {
  expect_length(erc("No code here."), 0L)
})

# ---------------------------------------------------------------------------
# get_base_url
# ---------------------------------------------------------------------------

test_that("get_base_url strips trailing slash", {
  old <- getOption("gptRBridge.base_url")
  on.exit(options(gptRBridge.base_url = old))
  options(gptRBridge.base_url = "https://example.com/")
  expect_equal(gptRBridge:::get_base_url(), "https://example.com")
})

test_that("get_base_url uses option when set", {
  old <- getOption("gptRBridge.base_url")
  on.exit(options(gptRBridge.base_url = old))
  options(gptRBridge.base_url = "https://my-backend.example.com")
  expect_equal(gptRBridge:::get_base_url(), "https://my-backend.example.com")
})
