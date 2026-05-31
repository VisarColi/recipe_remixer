import 'dotenv/config';
import express from 'express';
import OpenAI from 'openai';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const app = express();
const client = new OpenAI(); // reads OPENAI_API_KEY from env

app.use(express.json());
app.use(express.static(path.join(__dirname, 'build/web')));

const SYSTEM_PROMPT = `You are a culinary assistant that adapts recipes based on user constraints.
Respond with valid JSON ONLY — no markdown, no explanation, no code fences.

The JSON must exactly match this schema:
{
  "canAdapt": boolean,
  "reason": string,
  "adaptedRecipe": {
    "title": string,
    "ingredients": [string],
    "instructions": [string],
    "servings": string,
    "time": string
  },
  "whatChanged": [string],
  "metricIngredients": [string]
}

Rules:
- canAdapt: false when the recipe fundamentally cannot satisfy the constraint (e.g. beef steak → vegan because beef IS the dish). In that case, populate "reason" with a helpful explanation and a concrete alternative suggestion. Leave adaptedRecipe, whatChanged, and metricIngredients as null/empty.
- canAdapt: true for all other cases, including when the recipe already satisfies the constraint (note that in whatChanged).
- "ingredients" must use US imperial units (cups, oz, lbs, tsp, tbsp, °F).
- "metricIngredients" must be the same list in the same order, with all measurements converted to metric (ml, g, kg, °C). Keep non-convertible items (like "1 pinch") unchanged.
- "instructions" must be an array of strings, one step per element.
- "whatChanged" must be a concise list of the most important substitutions/adjustments (max 8 items). Do not restate the constraint — describe the actual changes.
- Never invent ingredients beyond what the constraint requires. Stay faithful to the original recipe's character.
- If scaling (e.g. halving), update all quantities in both ingredient lists.`;

function buildUserMessage(recipe, constraint) {
  return `Recipe:\n"""\n${recipe}\n"""\n\nConstraint: ${constraint}\n\nAdapt this recipe to satisfy the constraint and respond with the JSON schema described in the system prompt.`;
}

app.post('/api/remix', async (req, res) => {
  const { recipe, constraint } = req.body ?? {};

  if (!recipe?.trim() || !constraint?.trim()) {
    return res.status(400).json({ error: 'Both recipe and constraint are required.' });
  }

  try {
    const completion = await client.chat.completions.create({
      model: 'gpt-4o',
      messages: [
        { role: 'system', content: SYSTEM_PROMPT },
        { role: 'user', content: buildUserMessage(recipe, constraint) },
      ],
      response_format: { type: 'json_object' },
    });
    const parsed = JSON.parse(completion.choices[0].message.content);
    return res.json(parsed);
  } catch (err) {
    if (err instanceof SyntaxError) {
      return res.status(502).json({ error: 'Received an unexpected format from the AI. Please try again.' });
    }
    const msg = err.message ?? 'Server error. Please try again.';
    return res.status(502).json({ error: msg });
  }
});

// SPA fallback — any unmatched GET returns index.html so Flutter's router works
app.get('*', (_req, res) => {
  res.sendFile(path.join(__dirname, 'build/web', 'index.html'));
});

const PORT = process.env.PORT ?? 3000;
app.listen(PORT, () => console.log(`Recipe Remixer running on http://localhost:${PORT}`));
