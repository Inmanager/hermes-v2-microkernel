---
name: heavy-tool-subagent
description: Keep main session context lean by offloading ALL heavy MCP servers and disabled native tools to a temporary background subagent via Hermes CLI.
version: 1.2.0
---

# Heavy Tool Subagent Workflow

The user strictly prefers to keep the main session's context window extremely lean to save tokens and prevent AI distraction. Heavy MCP servers (like `chrome-devtools`, `minimax`, etc.) and non-essential native toolsets (like `image_gen`, `video`, `tts`, `homeassistant`, `spotify`, etc.) MUST remain disabled in the main interactive session.

When the user asks you to perform a task requiring a heavy tool (e.g., controlling a browser, generating/analyzing images or video, interacting with home assistant), you MUST use this subagent pattern instead of asking the user to enable the tool manually or telling them to run `/reset`.

## Strategies for Execution

You must identify whether the needed capability is an **MCP Server** or a **Native Toolset**, as the execution syntax differs.

### Strategy 1: For Native Toolsets (e.g., `image_gen`, `tts`, `homeassistant`)
You do NOT need to modify the global config. Instead, use the `-t` flag in `hermes chat` to dynamically inject the required toolset into the subagent.

Example Bash Command:
```bash
hermes chat -q "Generate an image of a cyberpunk city and save to /tmp/city.png" -t image_gen,file
```
*(Always include `file` if the subagent needs to read/write results to disk).*

### Strategy 2: For MCP Servers (e.g., `chrome-devtools`, `minimax`, `sqlite`)
You MUST toggle the MCP server globally via `hermes config` before and after the subagent run. You MUST use the `;` (semicolon) separator to guarantee the disable step runs even if the subagent fails.

Example Bash Command:
```bash
hermes config set mcp_servers.chrome-devtools.enabled true ; \
HERMES_HEAL=0 hermes chat -q "Navigate to example.com, extract the main heading, and return the text." ; \
hermes config set mcp_servers.chrome-devtools.enabled false
```

### Strategy 3: Multi-Step / Iterative Subagent
The `hermes chat -q` command is inherently **one-shot**. If the task requires multi-step reasoning (e.g., searching, then extracting, then analyzing), do NOT try to force the subagent to do it all in one `-q` command.
**Solution:** You (the main AI agent) must orchestrate the steps. Call the subagent for Step 1, read its output, formulate Step 2 based on that output, and call the subagent again for Step 2. You act as the brain, and the subagent acts as your hands.

## Important Pitfalls & Conventions

- **Context Isolation (Subagent Amnesia):** The `hermes chat -q` command runs a completely independent instance of Hermes. It does not know what you and the user were just talking about. You MUST provide all necessary context (URLs, explicit step-by-step instructions, file paths, expected output formats) directly inside the `-q` prompt.
- **Handling Large Outputs:** If the subagent is expected to return massive amounts of data (like a full page DOM, a long JSON, or a web scrape), instruct it to write to a temporary file:
  `hermes chat -q "Scrape XYZ and save to /tmp/scrape_result.md" -t web,file`
  Then use your `read_file` tool to read the result, preventing the terminal tool from truncating the stdout.
- **Cleanup Guarantee:** For MCPs, always use `;` (semicolon) before the disable command. Do NOT use `&&`, because if the `hermes chat` command fails, the `&&` short-circuits and leaves the heavy tool permanently enabled.
- **Power Loss / Hard Crash Vulnerability:** Semicolons and `trap` mechanisms do NOT survive a sudden power loss or `kill -9`. If a crash occurs mid-execution, the MCP config remains dirty (`true`). To fix this, implement a "Startup Auto-Heal" by appending a wrapper function to `~/.bashrc`. **CRITICAL:** The wrapper MUST verify that `chat` is in the arguments and check for `HERMES_HEAL!=0` to avoid breaking background subagents or slowing down basic commands like `--help`.
- **MCP Subprocess Environment Isolation:** Hermes does NOT automatically pass the host `.env` variables to MCP subprocesses. If you remove an API key from `config.yaml` for security, the MCP server will crash on startup. **Solution:** Create a bash wrapper script (e.g., `minimax-mcp.sh`) that uses `set -a; source ~/.hermes/.env; set +a; exec /absolute/path/to/uvx minimax-coding-plan-mcp "$@"`, and point the `config.yaml` `command` to this script with empty `env: {}`. Always use the absolute path to the binary (e.g., `~/.local/bin/uvx`) to survive missing `PATH` in cron/headless environments.
- **Do Not Modify the Main Session:** Do NOT tell the user to run `/reset` or `/tools`. Do the work silently in the background and present the final result.
