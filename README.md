# Recipe Remixer

Paste any recipe, add a constraint — "make it vegan", "halve it", "kid-friendly", "30-minute version" — and get back an adapted recipe with a plain-English summary of what changed. Includes an imperial ↔ metric unit toggle on the result screen.

## What it does

The app sends your recipe and constraint to Claude (claude-sonnet-4-6) via a Node.js proxy server. Claude returns structured JSON containing the adapted recipe, a parallel metric ingredient list, and a bullet-list of changes. If the adaptation is fundamentally impossible (e.g. "make a beef steak vegan"), Claude explains why and suggests an alternative rather than producing a broken recipe.

The frontend is built with Flutter Web and served as pre-compiled static files by the Express server. This means Replit only needs Node.js — no Flutter SDK required to run it.

## How to run on Replit

1. Fork this Repl (or import the GitHub repo via Replit's GitHub import)
2. Go to **Secrets** (the padlock icon) and add `ANTHROPIC_API_KEY` with your key from [console.anthropic.com](https://console.anthropic.com)
3. Click **Run** — you should see `Recipe Remixer running on http://localhost:3000`
4. Open the preview URL in the top pane

> Don't have an API key? Create a free account at [console.anthropic.com](https://console.anthropic.com), go to API Keys, and generate one.

## How to run locally

### Prerequisites
- Node.js 20+
- (Optional) Flutter SDK — only needed if you want to modify and rebuild the Flutter app

### Steps

```bash
git clone <your-repo-url>
cd recipe_remixer
npm install
cp .env.example .env      # then edit .env and add your ANTHROPIC_API_KEY
node server.js
# open http://localhost:3000
```

The `build/web/` directory is committed to the repo intentionally — see Architecture below. You don't need Flutter installed to run it.

### Rebuilding the Flutter app (optional)

```bash
flutter pub get
flutter build web --release
node server.js   # restart to pick up the new build
```

## Architecture

```
Browser
  └── Flutter Web SPA (build/web/ — pre-built, committed to repo)
        │
        └── POST /api/remix
              │
              └── Express server (server.js)
                    │
                    └── Anthropic API (claude-sonnet-4-6)
```

The Express server does two things: serve the pre-built Flutter web files as static assets, and proxy `/api/remix` calls to the Anthropic API. The API key never touches the browser.

`build/web/` is committed to the repo so that Replit (which has no Flutter SDK) can run the app with just `npm install && node server.js`. The `.gitignore` has a `!/build/web/` exception for this reason.

## Prompts used

These are the actual Claude Code prompts used to build this project:

---

> **Initial feature prompt:**
> "I have to implement this simple feature in web. Try to not make it too complicated: Recipe Remixer — Paste any recipe plus a constraint (vegan, halve it, 30-minute version, kid-friendly). Get back an adapted recipe with a 'what changed' summary. Must: recipe in, adapted recipe out, plus a short summary of changes. Handle a recipe that cannot be adapted with a useful response, not a crash. Bonus: imperial ↔ metric conversion toggle."

---

> **Architecture decision prompt:**
> "The project is currently a Flutter scaffold. Since you want a simple web app that runs easily on Replit, which approach should we take?" → chose Flutter Web + Node.js proxy, with `build/web/` committed so Replit only needs Node.js.

---

> **Claude system prompt (used verbatim in server.js):**
> ```
> You are a culinary assistant that adapts recipes based on user constraints.
> Respond with valid JSON ONLY — no markdown, no explanation, no code fences.
>
> The JSON must match this schema:
> { "canAdapt": boolean, "reason": string,
>   "adaptedRecipe": { "title", "ingredients", "instructions", "servings", "time" },
>   "whatChanged": [string], "metricIngredients": [string] }
>
> Rules: canAdapt false only when fundamentally impossible (e.g. beef steak → vegan).
> ingredients in imperial, metricIngredients same list in metric. whatChanged max 8 items.
> ```

---

> **Flutter UI prompt:**
> "Create a Flutter Web app with an input screen (recipe textarea + constraint field + Remix It button with loading overlay + suggestion chips) that navigates to a result screen showing adapted recipe, numbered instructions, imperial/metric toggle Switch, and a WhatChangedCard. Use setState, no external state packages."

---

## What I'd do with more time

- **Streaming responses** — use the Anthropic streaming API so ingredients appear progressively
- **Recipe history** — store past remixes in localStorage so users can browse what they've tried
- **Shareable links** — encode the result in a URL fragment so users can share their remix
- **Serving size slider** — drag from 1–12 servings and scale quantities without a new API call
- **Retry / error recovery** — exponential backoff on 529 (Anthropic overload) responses
- **Tests** — widget tests for input validation, unit tests for `RemixResult.fromJson` with malformed JSON fixtures
- **Proper deployment** — Railway or Fly.io with a persistent URL instead of Replit preview
