// Pi extension: register the Limen provider with model discovery.
//
// At startup it fetches /v1/models from the shim and maps each model's
// `context_window` to Pi's `contextWindow`, so the footer percentage and
// the compaction point follow what the shim reports. If the fetch fails
// (offline, missing key, shim not yet returning the field) it falls back
// to a static definition, so Pi still starts.
//
// Install: drop this file in ~/.pi/agent/extensions/ (plain name, no
// yadm ##os.Darwin suffix: Pi scans that directory) and restart Pi.
// The fetch runs once at startup; restart Pi to pick up a new value.
//
// Requires:
// - the shim to return `context_window` per model in /v1/models
//   (shipped: the shim reports 1000000 by default).
// - the Limen API key as LIMEN_API_KEY in Pi's environment, only for
//   the discovery fetch. The provider's own auth stays where it is.
// - the `limen` entry in ~/.pi/agent/models.json keeps baseUrl/apiKey/
//   headers but WITHOUT a static `models` list: models.json overrides
//   compose above extension registrations, so a static list there would
//   replace the discovered models and the discovery would be moot.

export default async function (pi) {
  const baseUrl = "https://ai.davidepucci.it/v1";
  const apiKey = process.env.LIMEN_API_KEY;
  let models = null;

  if (apiKey) {
    try {
      const res = await fetch(`${baseUrl}/models`, {
        headers: { Authorization: `Bearer ${apiKey}` },
      });
      if (res.ok) {
        const payload = await res.json();
        models = payload.data.map((m) => ({
          id: m.id,
          name: m.name ?? m.id,
          reasoning: false,
          input: ["text", "image"],
          cost: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0 },
          contextWindow: m.context_window ?? 1000000,
          maxTokens: m.max_tokens ?? 16384,
        }));
      }
    } catch {
      // Fall through to the static definition below.
    }
  }

  pi.registerProvider("limen", {
    baseUrl,
    api: "openai-completions",
    models: models ?? [
      {
        id: "tiro",
        name: "tiro",
        reasoning: false,
        input: ["text", "image"],
        cost: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0 },
        contextWindow: 1000000,
        maxTokens: 16384,
      },
    ],
  });
}
