import logging
import os
from typing import Any

logger = logging.getLogger("plugin.global_auto_heal")

def _heal(*args, **kwargs) -> None:
    if os.environ.get("HERMES_HEAL") == "0":
        return
    try:
        from hermes_cli.config import load_config, set_config_value
        cfg = load_config()
        changed = False
        mcp = cfg.get("mcp_servers") or {}
        # Extract targets from environment variable or use default
        env_targets = os.environ.get("HERMES_HEAVY_MCPS")
        if env_targets:
            targets = [t.strip() for t in env_targets.split(",")]
        else:
            # If not specified, do not block any to prevent breaking other users' setups
            targets = []
            
        if not targets:
            return
        for server in targets:
            if mcp.get(server, {}).get("enabled", False):
                set_config_value(f"mcp_servers.{server}.enabled", "false")
                changed = True
        if changed:
            logger.info("[Global Auto-Heal] Successfully blocked heavy MCP servers.")
    except Exception as e:
        logger.error(f"[Global Auto-Heal] Failed to block MCP servers: {e}")

def register(ctx: Any) -> None:
    # Run _heal() immediately at load time to catch cold starts
    _heal()
    ctx.register_hook("on_session_start", _heal)
    ctx.register_hook("on_session_end", _heal)
    ctx.register_hook("on_session_reset", _heal)
    ctx.register_hook("on_session_finalize", _heal)
