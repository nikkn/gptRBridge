# Get Started with gptRBridge

## What is gptRBridge?

**gptRBridge** is the fastest way to get GPT inside RStudio. No API
account, no setup, no configuration. Install, register, and start
working in under 2 minutes.

Every other R/GPT package requires you to:

- Create an account with an AI provider
- Set up billing and generate API keys
- Manage environment variables in `.Renviron`
- Handle rate limits and model versioning yourself

gptRBridge removes all of that. We handle the infrastructure. You just
use it.

------------------------------------------------------------------------

## Installation

Install directly from GitHub:

``` r
install.packages("remotes")
remotes::install_github("nikkn/gptRBridge", upgrade = "never")
```

Then restart RStudio so the addin appears in your Addins menu.

------------------------------------------------------------------------

## Step 1: Launch the addin

In RStudio, go to **Addins → gptRBridge**, or run:

``` r
gptRBridge::launch_addin()
```

The chat panel opens in your RStudio Viewer pane.

------------------------------------------------------------------------

## Step 2: Create a free account

Click **Register** in the addin. You will need:

- An email address
- A password (minimum 8 characters)
- A credit card (for fraud protection, **you are not charged** during
  your free trial)

> **Why a credit card?** We pay for every API call on your behalf. The
> card requirement prevents abuse, the same approach used by AWS and
> Google Cloud free tiers. Your first 50 calls are completely free.

After registering, a browser window will open for card verification.
Once verified, your 50 free trial calls are activated and you can start
chatting immediately.

------------------------------------------------------------------------

## Step 3: Start chatting

Type any question about your R code, data, or analysis:

    How do I reshape a data frame from wide to long format?

    Explain what this error means:
    Error in lm.fit(x, y, offset = offset, singular.ok = singular.ok, ...) :
      NA/NaN/Inf in 'x'

The assistant responds with explanations and ready-to-run code blocks.

------------------------------------------------------------------------

## Step 4: Insert code

Click the **Insert** button on any code block to place it directly into
your active RStudio editor with one click. No copy-pasting needed.

------------------------------------------------------------------------

## Step 5: Iterate automatically

Console output, results, and errors are captured automatically and
passed back to the assistant. Enable **“Insert output automatically”**
in the chat panel. Then just run your code, see the result, and ask a
follow-up question without leaving RStudio or touching your clipboard.

------------------------------------------------------------------------

## Your free trial

Your first **50 calls are free**. No time limit, use them at your own
pace.

After that, a subscription is **\$9.99/month** for full access, subject
to fair-use limits that only apply to extreme abuse scenarios. Normal
users never hit them.

------------------------------------------------------------------------

## Pricing summary

|                    | Free Trial    | Subscription |
|--------------------|---------------|--------------|
| **Cost**           | \$0           | \$9.99/month |
| **Calls**          | 50 (one-time) | Unlimited\*  |
| **Setup required** | None          | None         |

\*Fair-use limits apply only to extreme abuse scenarios.

------------------------------------------------------------------------

## Troubleshooting

**The addin does not appear in my Addins menu** Restart RStudio after
installation. If it still does not appear, run
[`library(gptRBridge)`](https://nikkn.github.io/gptRBridge/) first.

**Registration fails** Check your internet connection. If the problem
persists, open an issue on
[GitHub](https://github.com/nikkn/gptRBridge/issues).

**“Session expired” or login error** Close and relaunch the addin. You
will be logged in automatically if your session is still valid. If not,
log in again with your email and password.

------------------------------------------------------------------------

## Next steps

- Check the [FAQ](https://nikkn.github.io/gptRBridge/articles/faq.md)
  for common questions
- [Open an issue](https://github.com/nikkn/gptRBridge/issues) if
  something does not work
