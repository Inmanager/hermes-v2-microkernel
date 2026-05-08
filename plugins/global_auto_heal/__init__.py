import logging
from typing import Any

logger = logging.getLogger("plugin.global_auto_heal")

def _heal(*args, **kwargs) -> None:
    try:
        from hermes_cli.config import load_config, set_config_value
        cfg = load_config()
        changed = False
        mcp = cfg.get("mcp_servers", {})
        for server in ["minimax", "chrome-devtools"]:
            if mcp.get(server, {}).get("enabled", False):
                set_config_value(f"mcp_servers.{server}.enabled", "false")
                changed = True
        if changed:
            logger.info("[Global Auto-Heal] Successfully blocked heavy MCP servers.")
    except Exception as e:
        logger.error(f"[Global Auto-Heal] Failed to block MCP servers: {e}")

def register(ctx: Any) -> None:
    ctx.register_hook("on_session_start", _heal)
    ctx.register_hook("on_session_end", _heal)
    ctx.register_hook("on_session_reset", _heal)
    ctx.register_hook("on_session_finalize", _heal)
