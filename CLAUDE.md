# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

### Run the app (Node.js only — no Flutter needed)
```bash
node server.js        # requires OPENAI_API_KEY in .env
npm run dev           # same, with --watch for auto-restart
```

### Rebuild the Flutter frontend
```bash
flutter pub get
flutter build web --release   # output goes to build/web/
```
`build/web/` is committed intentionally — Replit has no Flutter SDK, so the pre-built output is what makes the app deployable there without any build step.

### Test the API endpoint directly
```bash
curl -X POST http://localhost:3000/api/remix \
  -H "Content-Type: application/json" \
  -d '{"recipe":"1 cup milk, 1 egg, 1 cup flour. Mix and cook.","constraint":"make it vegan"}'
```

## Architecture

Two separate runtimes talking to each other at one boundary:

**Node.js (`server.js`)** — the only process that runs in production/Replit:
- Serves the pre-built Flutter web SPA from `build/web/` as static files.
- Exposes `POST /api/remix` which calls OpenAI (`gpt-4o`) and returns structured JSON.
- SPA fallback (`GET *`) ensures Flutter's client-side router works for any unmatched path.

**Flutter (`lib/`)** — compiled to `build/web/` and served as static files:
- `RemixService` POSTs to `/api/remix` using a relative URL (same-origin). This only works because Flutter is served by the same Express process. For `flutter run` local dev, the server must be on the same port.
- `RemixResult` / `AdaptedRecipe` are the typed models. `fromJson` is defensive (`List<String>.from(...)`) so a malformed API response throws a clear `RemixException` rather than a type error inside widget code.
- `canAdapt: false` responses are handled on `ResultScreen` (not in the service layer) — the service always returns a `RemixResult`; it's the data that signals whether adaptation succeeded.

## API contract

`POST /api/remix` — request: `{ recipe: string, constraint: string }`

Response shape (always JSON):
```json
{
  "canAdapt": true,
  "reason": "",
  "adaptedRecipe": { "title", "ingredients", "instructions", "servings", "time" },
  "whatChanged": ["..."],
  "metricIngredients": ["..."]
}
```
`ingredients` is imperial; `metricIngredients` is the same list in the same order converted to metric. The Flutter metric toggle simply swaps which list is rendered — no client-side conversion math.

When `canAdapt` is false, `adaptedRecipe`, `whatChanged`, and `metricIngredients` are empty/null and `reason` contains the explanation.

## Environment

- `OPENAI_API_KEY` — required. Put it in `.env` (gitignored). `.env.example` is the template.
- `PORT` — optional, defaults to 3000.
