# gptRBridge

**Plug-and-play GPT access for RStudio. No OpenAI account needed.**

Unlike other AI tools for R that require you to set up your own API account, gptRBridge is ready to go out of the box. Install the package, register in under 2 minutes, and start working immediately. No API keys, no configuration, we handle everything.

---

## Features

- Conversational AI chat panel inside RStudio
- Generated R code with one-click insertion into the active editor
- Send console output or error messages back for instant diagnosis
- Powered by GPT (cutting-edge language models)
- Secure account system, your data stays yours

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

Register with your email and password. You receive **50 free trial calls** at no cost. A credit card is required for identity verification only. Since we cover the cost of your trial, we need to ensure each account is legitimate. You will not be charged unless you explicitly subscribe after your trial ends.

**3. Start chatting**

Ask anything about your data, models, or R code. The assistant responds with explanations and ready-to-run code blocks.

**4. Insert code**

Click the **Insert** button on any code block to insert it directly into your active RStudio editor.

---

## Pricing

| | |
|---|---|
| **Trial** | 50 free calls, no charge |
| **Subscription** | $9.99/month, cancel anytime |

Your first 50 calls are completely free. After that, a flat subscription of **$9.99/month** gives you full access. One simple price, no usage surprises.

---

## License

This software is free to use for personal and academic purposes.
Commercial use and redistribution require written permission.
See [LICENSE.md](LICENSE.md) for full terms.

© 2026 Nikolai Alexander
