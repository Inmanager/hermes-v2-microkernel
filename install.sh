#!/bin/bash
# Hermes Agent V2 Microkernel Architecture Installer
set -e

echo "🚀 Installing Hermes V2 Microkernel Architecture..."

HERMES_DIR="${HOME}/.hermes"
BASHRC="${HOME}/.bashrc"
BRIDGE_SCRIPT="${HERMES_DIR}/minimax-mcp.sh"

# 1. Create the MCP Bridge Script
echo "📦 Creating Secure MCP Bridge Script..."
mkdir -p "${HERMES_DIR}"
cat > "${BRIDGE_SCRIPT}" << 'EOF'
#!/bin/bash
# Hermes V2 Secure MCP Bridge
# Extract the key safely WITHOUT using `source` to prevent arbitrary code execution from malicious .env payloads
RAW_KEY=$(grep -E '^MINIMAX_API_KEY=' ~/.hermes/.env 2>/dev/null | cut -d '=' -f2- | sed -e 's/^"//' -e 's/"$//' -e "s/^'//" -e "s/'$//")
# Strip accidental trailing/leading whitespaces safely
export MINIMAX_API_KEY=$(printf '%s\n' "$RAW_KEY" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
export MINIMAX_API_HOST=https://api.minimaxi.com/v1
# Execute the MCP server using $HOME for portability
exec "$HOME/.local/bin/uvx" minimax-coding-plan-mcp "$@"
EOF
chmod +x "${BRIDGE_SCRIPT}"

# 2. Inject the Bash Wrapper
echo "🛡️ Injecting Anti-Pollution Bash Wrapper into ~/.bashrc..."
if ! grep -q "# Hermes Auto-Heal Wrapper" "${BASHRC}"; then
cat >> "${BASHRC}" << 'EOF'

# Hermes Auto-Heal Wrapper (V2 Microkernel)
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
        if [[ "$is_chat" == true ]]; then
            command hermes config set mcp_servers.minimax.enabled false >/dev/null 2>&1
            command hermes config set mcp_servers.chrome-devtools.enabled false >/dev/null 2>&1
        fi
    fi
    command hermes "$@"
}
EOF
else
    echo "⚠️ Bash wrapper already exists, skipping."
fi

# 3. Patch config.yaml safely
echo "⚙️ Optimizing config.yaml settings..."
if [ -f "${HERMES_DIR}/config.yaml" ]; then
    # We use sed to safely update properties if they exist
    sed -i 's/target_ratio: .*/target_ratio: 0.5/g' "${HERMES_DIR}/config.yaml"
    sed -i 's/threshold: .*/threshold: 0.03/g' "${HERMES_DIR}/config.yaml"
    echo "✅ Compression parameters optimized."
else
    echo "⚠️ config.yaml not found, please configure Hermes first."
fi

echo "🎉 Installation Complete! Please run 'source ~/.bashrc' or restart your terminal."
