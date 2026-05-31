# Recipe Remixer

Paste any recipe, add a constraint — "make it vegan", "halve it", "kid-friendly", "30-minute version" — and get back an adapted recipe with a plain-English summary of what changed. Includes an imperial ↔ metric unit toggle on the result screen.

## What it does

The app sends your recipe and constraint to OpenAI (gpt-4o) via a Node.js proxy server. GPT-4o returns structured JSON containing the adapted recipe, a parallel metric ingredient list, and a bullet-list of changes. If the adaptation is fundamentally impossible (e.g. "make a beef steak vegan"), it explains why and suggests an alternative rather than producing a broken recipe.

The frontend is built with Flutter Web and served as pre-compiled static files by the Express server. This means Replit only needs Node.js — no Flutter SDK required to run it.

## How to run on Replit

1. Fork this Repl (or import the GitHub repo via Replit's GitHub import)
2. Go to **Secrets** (the padlock icon) and add `OPENAI_API_KEY` with your key from [platform.openai.com](https://platform.openai.com)
3. Click **Run** — you should see `Recipe Remixer running on http://localhost:3000`
4. Open the preview URL in the top pane

> Don't have an API key? Create an account at [platform.openai.com](https://platform.openai.com), go to API Keys, and generate one.

## How to run locally

### Prerequisites

**Node.js 20+** (required)

- **Windows:** run `winget install OpenJS.NodeJS.LTS` in PowerShell, then close and reopen the terminal
- **Mac:** run `brew install node` (requires [Homebrew](https://brew.sh))
- **Linux:** run `sudo apt install nodejs npm`

Verify with: `node --version`

**Flutter SDK** (optional — only needed if you want to modify and rebuild the frontend)

### Steps

```bash
git clone <your-repo-url>
cd recipe_remixer
npm install
```

Create a `.env` file in the project root with your OpenAI API key:
```
OPENAI_API_KEY=sk-...your key here...
```
> Get a key at [platform.openai.com](https://platform.openai.com) → API Keys → Create new secret key.

```bash
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
                    └── OpenAI API (gpt-4o)
```

The Express server does two things: serve the pre-built Flutter web files as static assets, and proxy `/api/remix` calls to the OpenAI API. The API key never touches the browser.

`build/web/` is committed to the repo so that Replit (which has no Flutter SDK) can run the app with just `npm install && node server.js`. The `.gitignore` has a `!/build/web/` exception for this reason.

## Prompts used to build this project

> "Build a Recipe Remixer web app. paste any recipe plus a constraint (vegan, halve it, 30-minute version, kid-friendly) and get back an adapted recipe with a summary of what changed. Handle cases where adaptation is impossible with a helpful response, not a crash."

> "Use Flutter Web for the frontend and a Node.js/Express backend as a proxy to the OpenAI API (gpt-4o). Commit the pre-built Flutter output to the repo so the app can run on Replit without a Flutter SDK."

> "The API should return structured JSON with the adapted recipe, a parallel metric ingredient list, and a bullet-list of changes. If adaptation is fundamentally impossible, return a reason and alternative suggestion instead."

> "Create a Flutter UI with an input screen (recipe textarea, constraint field, Remix It button with loading overlay, suggestion chips) and a result screen showing the adapted recipe, numbered instructions, imperial/metric toggle, and a What Changed card. Use setState only — no external state packages."

> "Include an imperial ↔ metric unit toggle on the result screen."

---

## What I'd do with more time

- **Recipe history** — store past remixes in localStorage so users can browse what they've tried
- **Shareable links** — encode the result in a URL fragment so users can share their remix
- **Retry / error recovery** — exponential backoff on OpenAI rate-limit (429) responses
- **Tests** — widget tests for input validation, unit tests for `RemixResult.fromJson` with malformed JSON fixtures


## System prompt (used verbatim in server.js)

```
You are a culinary assistant that adapts recipes based on user constraints.
Respond with valid JSON ONLY — no markdown, no explanation, no code fences.

The JSON must match this schema:
{ "canAdapt": boolean, "reason": string,
  "adaptedRecipe": { "title", "ingredients", "instructions", "servings", "time" },
  "whatChanged": [string], "metricIngredients": [string] }

Rules: canAdapt false only when fundamentally impossible (e.g. beef steak → vegan).
ingredients in imperial, metricIngredients same list in metric. whatChanged max 8 items.
```

