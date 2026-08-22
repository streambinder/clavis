// Local MLX provider on port 8000 — served by mlx-serve (was oMLX until 2026-08-22).
//
// The port is shared with oMLX on purpose so the two can never run at once:
// oMLX binds through uvicorn bind_socket() (SO_REUSEADDR only), so whichever
// starts second gets EADDRINUSE. Falling back is therefore just:
//   launchctl unload -w ~/Library/LaunchAgents/local.mlx-serve.plist
//   brew services start jundot/omlx/omlx
// (the -w matters, or mlx-serve returns at next login and races for the port).
// oMLX's own config was untracked in the same commit that added the launchd
// agent — recover it from git history if you go back.
//
// One model, deliberately. The context window is sized against real KV cost,
// not guesswork: Qwen3.6 is hybrid GDN, so only 10 of its 40 layers keep a KV
// cache (full_attention_interval=4, 2 KV heads) and 262K context costs ~5 GB.
export default function (pi) {
  const free = { input: 0, output: 0, cacheRead: 0, cacheWrite: 0 };

  pi.registerProvider("local", {
    baseUrl: "http://127.0.0.1:8000/v1",
    apiKey: "omlx", // ignored by mlx-serve, which runs unauthenticated
    api: "openai-completions",
    models: [
      {
        id: "Jundot--Qwen3.6-35B-A3B-oQ4e-mtp",
        name: "Qwen3.6-35B-A3B oQ4e+MTP",
        reasoning: false,
        input: ["text", "image"],
        cost: free,
        // 16.7 GB resident. Same arch + quant as the stock mlx-community 4bit
        // (qwen3_5_moe_text, 256 experts / 8 active, 4-bit affine gs64) plus a
        // 42-tensor MTP head the stock build does NOT have.
        // mlx-serve derives this exact id from the basename of the symlink at
        // ~/.mlx-serve/models/<id>, which is why no config changed when the
        // server did. It must exist -- see the launchd plist for the command.
        // Measured vs oMLX 0.6.3rc2, same weights, quiet machine: decode
        // 174 -> 206 tok/s, warm TTFT 0.84 -> 0.27 s, agentic tool loop
        // 8.3 -> 2.7 s/round, 25/25 tool calls both. The win is ~0.57 s of
        // fixed per-request overhead, not compute -- cold prefill ties.
        // Also a VLM: reads code screenshots and charts correctly.
        // Thinking works via chat_template_kwargs.enable_thinking but it
        // overthinks easy problems -- 2690 reasoning tokens on bat-and-ball.
        // Left off via defaultThinkingLevel in settings.json.
        contextWindow: 262144,
        maxTokens: 32768,
      },
    ],
    compat: {
      supportsDeveloperRole: false,
      maxTokensField: "max_tokens",
    },
  });
}
