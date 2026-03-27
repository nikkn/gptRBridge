# Frequently Asked Questions

## General

**How do I activate my free trial?** After registering, you will receive
a verification email. Click the link to verify your address and activate
your 25 free trial calls. No credit card required.

**Why not just let me use my own API key?** That is exactly what every
other R/GPT package already does. gptRBridge exists for people who do
not want to manage their own API account, billing, key rotation, or
model versioning. If you prefer to use your own key, there are great
options like `gptstudio` or `ellmer`.

**Which model does gptRBridge use?** We currently use the latest GPT-5
mini model, which delivers excellent results for coding and data
analysis tasks at a cost that keeps the subscription affordable. We
update the model regularly to keep up with new developments.

**Is my code and data safe?** No code or conversations are stored.
Requests pass through a stateless backend to the AI API and nothing is
logged or persisted. Chat history lives only in your local RStudio
session and disappears when you close the addin. Credit card details are
handled entirely by Stripe when you subscribe. We never see or store
card numbers. The only data we store is your account status and usage
count for billing.

------------------------------------------------------------------------

## Pricing & Billing

**What happens after my 25 free calls?** You will be prompted to
subscribe for \$4.99/month. Until you subscribe, the addin will show a
“trial ended” message.

**Can I cancel anytime?** Yes. Cancel from your account dashboard at any
time with no cancellation fees.

**Are there usage limits on the subscription?** There are soft fair-use
limits to prevent abuse, but normal usage, even heavy daily use, will
never hit them.

------------------------------------------------------------------------

## Technical

**Does gptRBridge work outside of RStudio?** The addin UI requires
RStudio. The one-click insert and console capture features are
RStudio-specific.

**Does it work on RStudio Server / Posit Workbench?** Yes, as long as
the server has outbound internet access.

**Can I use it offline?** No. gptRBridge requires an internet connection
to reach our backend.

------------------------------------------------------------------------

## Still have questions?

Open an issue on [GitHub](https://github.com/nikkn/gptRBridge/issues) or
email us at <contact.aquart@gmail.com>.
