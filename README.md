# gptRBridge

**An AI-powered assistant for RStudio — chat with GPT, get R code, insert it directly into your editor.**

gptRBridge brings a conversational AI interface into RStudio. Ask questions about your data, get working R code suggestions, send error messages back for instant diagnosis, and insert code into your script with a single click.

---

## Features

- Conversational AI chat panel inside RStudio
- Generated R code with one-click insertion into the active editor
- Send console output or error messages to the AI for iterative refinement
- Powered by GPT (cutting-edge OpenAI models)
- Secure account system — your data stays yours

---

## Requirements

- R >= 4.1
- RStudio
- An internet connection

---

## Installation

Run the following in R:

```r
install.packages("remotes")
remotes::install_github("nikkn/gptRBridge", upgrade = "never")
```

---

## Getting Started

**1. Launch the addin**

```r
gptRBridge::launch_addin()
```

Or via the RStudio menu: **Addins → Launch GPT-R-Bridge**

**2. Create a free account**

On first launch, register with your email and password. You receive **50 free API calls** to explore the tool.

**3. Start chatting**

Ask anything about your data, models, or R code. The AI responds with explanations and ready-to-run code blocks.

**4. Insert code**

Click the **Insert** button on any code block to insert it directly into your active RStudio editor.

---

## Subscription

After your 50 free calls, a subscription is required to continue. Click **Subscribe now** in the addin or contact us at [contact.aquart@gmail.com](mailto:contact.aquart@gmail.com).

---

## License

This software is free to use for personal and academic purposes.
Commercial use and redistribution require written permission.
See [LICENSE.md](LICENSE.md) for full terms.

© 2026 Nikolai Alexander
