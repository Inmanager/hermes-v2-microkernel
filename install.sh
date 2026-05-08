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

TARGET_KEY="$1"
shift

# Extract the key safely WITHOUT using `source` to prevent arbitrary code execution from malicious .env payloads
# Also support `.env` files that have `export KEY=VALUE` syntax, and take the last match if duplicated
RAW_KEY=$(grep -E "^(export[[:space:]]+)?${TARGET_KEY}=" ~/.hermes/.env 2>/dev/null | tail -n 1 | cut -d '=' -f2- | sed -e 's/^"//' -e 's/"$//' -e "s/^'//" -e "s/'$//")
# Strip accidental trailing/leading whitespaces safely
export "${TARGET_KEY}=$(printf '%s\n' "$RAW_KEY" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"

# Specific handling for known services if needed (e.g. Minimax needs a specific API Host)
if [ "$TARGET_KEY" = "MINIMAX_API_KEY" ]; then
    export MINIMAX_API_HOST=https://api.minimaxi.com/v1
fi

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
    if ! grep -q "# Hermes Auto-Heal Wrapper" "${RC_FILE}"; then
        echo "   -> Injecting into ${RC_FILE}..."
        cat >> "${RC_FILE}" << 'EOF'

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
            # Use tr to split and iterate over targets to be compatible with both Bash and Zsh word splitting behaviors
            for target in $(echo "$HERMES_HEAVY_MCPS" | tr ',' ' '); do
                # Trim whitespace (if any remain) and strip potential wildcard expansion
                # We turn off globbing to safely process target names that might contain wildcards (though rare for tool names)
                set -f
                target=$(echo "$target" | xargs)
                set +f
                if [[ -n "$target" ]]; then
                    command hermes config set "mcp_servers.${target}.enabled" false >/dev/null 2>&1
                fi
            done
        fi
    fi
    command hermes "$@"
}
EOF
    else
        echo "⚠️ Wrapper already exists in ${RC_FILE}, skipping."
    fi
done

# 3. Patch config.yaml safely (Cross-Platform compatibility for sed)
echo "⚙️ Optimizing config.yaml settings..."
if [ -f "${HERMES_DIR}/config.yaml" ]; then
    tmp_config=$(mktemp)
    sed 's/target_ratio: .*/target_ratio: 0.5/g; s/threshold: .*/threshold: 0.03/g' "${HERMES_DIR}/config.yaml" > "$tmp_config"
    mv "$tmp_config" "${HERMES_DIR}/config.yaml"
    echo "✅ Compression parameters optimized."
else
    echo "⚠️ config.yaml not found, please configure Hermes first."
fi

# 4. Install Microkernel Skills
echo "🧠 Installing Microkernel Architecture Skills..."
if [ -d "skills" ]; then
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
    command hermes plugins enable global_auto_heal >/dev/null 2>&1
    echo "✅ Global Auto-Heal plugin installed and enabled."
else
    echo "⚠️ Plugins directory not found in repository."
fi

echo "🎉 Installation Complete! Please restart your terminal, or source your shell configuration file (e.g., 'source ~/.bashrc' or 'source ~/.zshrc')."
