#!/bin/bash
# Hermes Agent V2 Microkernel Architecture Installer
set -e

echo "🚀 Installing Hermes V2 Microkernel Architecture..."

HERMES_DIR="${HOME}/.hermes"
BRIDGE_SCRIPT="${HERMES_DIR}/secure-mcp-wrapper.sh"

# 1. Create the General Secure MCP Bridge Script
echo "📦 Creating Secure MCP Bridge Script..."
mkdir -p "${HERMES_DIR}"
cat > "${BRIDGE_SCRIPT}" << 'EOF'
#!/bin/bash
# Hermes V2 Secure MCP Bridge (Universal)
# Usage: ./secure-mcp-wrapper.sh <ENV_KEY_TO_EXTRACT> <COMMAND_TO_EXECUTE...>
# Example: ./secure-mcp-wrapper.sh MINIMAX_API_KEY "$HOME/.local/bin/uvx" minimax-coding-plan-mcp "$@"

if [ "$#" -lt 2 ]; then
    echo "Usage: $0 <ENV_KEY_TO_EXTRACT> <COMMAND...>"
    exit 1
fi

    # Support multiple keys separated by comma, e.g., KEY1,KEY2
    # Since this script is #!/bin/bash, we can use bash features safely.
    IFS=',' read -ra KEYS <<< "$1"
    for TARGET_KEY in "${KEYS[@]}"; do
        # Trim whitespace
        TARGET_KEY=$(echo "$TARGET_KEY" | tr -d ' ')
        if [ -n "$TARGET_KEY" ] && [ -z "${!TARGET_KEY}" ]; then
            # Extract the key safely WITHOUT using `source` to prevent arbitrary code execution from malicious .env payloads
            RAW_KEY=$(grep -E "^(export[[:space:]]+)?${TARGET_KEY}=" ~/.hermes/.env 2>/dev/null | tail -n 1 | cut -d '=' -f2- | tr -d '\r' | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' -e 's/^"//' -e 's/"$//' -e "s/^'//" -e "s/'$//")
            export "${TARGET_KEY}=${RAW_KEY}"
        fi
    done
    shift

# Execute the MCP server
exec "$@"
EOF
chmod +x "${BRIDGE_SCRIPT}"

# 2. Inject the Bash/Zsh Wrapper
echo "🛡️ Injecting Anti-Pollution Wrapper into shell configs..."

RC_FILES=()
[ -f "${HOME}/.bashrc" ] && RC_FILES+=("${HOME}/.bashrc")
[ -f "${HOME}/.zshrc" ] && RC_FILES+=("${HOME}/.zshrc")
# Fallback to .bashrc if neither exists
if [ ${#RC_FILES[@]} -eq 0 ]; then
    RC_FILES+=("${HOME}/.bashrc")
fi

for RC_FILE in "${RC_FILES[@]}"; do
    if grep -q "# Hermes Auto-Heal Wrapper" "${RC_FILE}" 2>/dev/null; then
        echo "   -> Updating existing wrapper in ${RC_FILE}..."
        tmp_rc=$(mktemp)
        awk '
          BEGIN { in_wrapper = 0; new_format = 0 }
          /^# --- BEGIN HERMES AUTO-HEAL WRAPPER ---/ {
              in_wrapper = 1
              new_format = 1
              next
          }
          /^# Hermes Auto-Heal Wrapper/ && in_wrapper == 0 {
              in_wrapper = 1
              new_format = 0
              next
          }
          in_wrapper {
              if (new_format == 1) {
                  if (/^# --- END HERMES AUTO-HEAL WRAPPER ---/) {
                      in_wrapper = 0
                  }
              } else {
                  if (/^}$/) {
                      in_wrapper = 0
                  }
              }
              next
          }
          { print }
        ' "${RC_FILE}" > "$tmp_rc"
        cat "$tmp_rc" > "${RC_FILE}"
        rm -f "$tmp_rc"
    else
        echo "   -> Injecting into ${RC_FILE}..."
    fi
    cat >> "${RC_FILE}" << 'EOF'

# --- BEGIN HERMES AUTO-HEAL WRAPPER ---
# Hermes Auto-Heal Wrapper (V2 Microkernel)
# Make sure to set HERMES_HEAVY_MCPS="minimax,chrome-devtools" in your environment if you want to block heavy tools.
hermes() {
    if [[ "$HERMES_HEAL" != "0" ]]; then
        local is_chat=false
        if [[ $# -eq 0 ]]; then is_chat=true; else
            for arg in "$@"; do
                if [[ "$arg" != -* ]]; then
                    if [[ "$arg" == "chat" ]]; then is_chat=true; fi
                    break
                fi
            done
        fi
        if [[ "$is_chat" == true && -n "$HERMES_HEAVY_MCPS" ]]; then
            # Fast-path: Only execute CLI config resets if there is a risk of dirty config (enabled: true/\"true\" exists)
            if grep -qiE "enabled:[[:space:]]*['\"]?true['\"]?" "$HOME/.hermes/config.yaml" 2>/dev/null; then
                printf '%s\n' "$HERMES_HEAVY_MCPS" | tr -d ' ' | tr ',' '\n' | while read -r target; do
                    if [[ -n "$target" ]] && grep -q "$target" "$HOME/.hermes/config.yaml" 2>/dev/null; then
                        command hermes config set "mcp_servers.${target}.enabled" false >/dev/null 2>&1
                    fi
                done
            fi
        fi
    fi
    command hermes "$@"
}
# --- END HERMES AUTO-HEAL WRAPPER ---
EOF
done

# 3. Patch config.yaml safely (Use CLI if available, fallback to safe sed)
echo "⚙️ Optimizing config.yaml settings..."
if command -v hermes >/dev/null 2>&1; then
    command hermes config set compression.target_ratio 0.5 >/dev/null 2>&1 || true
    command hermes config set compression.threshold 0.03 >/dev/null 2>&1 || true
    echo "✅ Compression parameters optimized via Hermes CLI."
elif [ -f "${HERMES_DIR}/config.yaml" ]; then
    tmp_config=$(mktemp)
    sed -e 's/^\([[:space:]]*\)target_ratio: .*/\1target_ratio: 0.5/g' -e 's/^\([[:space:]]*\)threshold: .*/\1threshold: 0.03/g' "${HERMES_DIR}/config.yaml" > "$tmp_config"
    cat "$tmp_config" > "${HERMES_DIR}/config.yaml"
    rm -f "$tmp_config"
    echo "✅ Compression parameters optimized via fallback sed."
else
    echo "⚠️ config.yaml not found, please configure Hermes first."
fi

# 4. Install Microkernel Skills
echo "🧠 Installing Microkernel Architecture Skills..."
if [ -d "skills" ]; then
    mkdir -p "${HERMES_DIR}/skills/"
    cp -r skills/* "${HERMES_DIR}/skills/"
    echo "✅ Sub-agent and Maintenance skills installed."
else
    echo "⚠️ Skills directory not found in repository."
fi

# 5. Install Global Auto-Heal Plugin
echo "🔌 Installing Global Auto-Heal Plugin for cross-platform protection..."
if [ -d "plugins" ]; then
    mkdir -p "${HERMES_DIR}/hermes-agent/plugins/"
    cp -r plugins/* "${HERMES_DIR}/hermes-agent/plugins/"
    command hermes plugins enable global_auto_heal >/dev/null 2>&1 || true
    echo "✅ Global Auto-Heal plugin installed and enabled."
else
    echo "⚠️ Plugins directory not found in repository."
fi

echo "🎉 Installation Complete! Please restart your terminal, or source your shell configuration file (e.g., 'source ~/.bashrc' or 'source ~/.zshrc')."
