# Hermes V2 Microkernel

[English](README.md) | [中文版](README_zh.md)

Hermes V2 Microkernel is a lightweight, secure, and resilient architecture designed for Hermes Agent. 

### 🎯 Core Goal: Drastically Reduce Token Consumption
In traditional AI Agent setups, every single interaction sends all tool descriptions, numerous predefined skills, and lengthy system prompts to the LLM. This leads to bloated context windows, enormous token consumption, high costs, and slower response times.

**How does this project solve the problem? (A Beginner's Guide)**

1. **On-Demand Tool Loading (via MCP)**:
   Instead of feeding all tool descriptions to the AI at once, the Microkernel acts as a dispatcher. It dynamically loads the specific tool capability via the Model Context Protocol (MCP) *only* when the AI actually needs to perform a task. Once the task is done, the tool context is released, keeping the active memory clean.

2. **Migrating "Skills" into MemPalace**:
   Complex operational manuals and workflow procedures (Skills) that the AI used to memorize in the main prompt are now extracted and stored in a dedicated memory system called MemPalace. When the AI faces a specific scenario, the Microkernel retrieves just the relevant snippet of knowledge. This keeps the main LLM context extremely lean.

By implementing this "On-Demand Loading + Memory Offloading" mechanism, the Microkernel prevents context bloat and **drastically reduces token costs per conversation**.

Additionally, it provides robust environmental protection, global auto-healing, and optimized configuration management to ensure a stable agent environment.

## Features

- **Secure MCP Bridge**: Provides a secure bridge script for MCP tools, preventing arbitrary code execution and credential leaks via strict environment variable parsing.
- **Anti-Pollution Shell Wrapper**: Injects protective wrappers into shell configurations (`.bashrc`, `.zshrc`) with deep multi-line nested config detection to prevent YAML parsing escapes.
- **Global Auto-Heal Plugin**: Automatically heals corrupted configurations and prevents system crashes with strict type validation.
- **Microkernel Skills**: Includes essential sub-agent and maintenance skills for seamless autonomous operation.
- **Cross-Platform Compatibility**: Fully compatible with Linux, macOS, and BSD environments.

## Installation

Run the installation script to deploy the microkernel architecture:

```bash
chmod +x install.sh
./install.sh
```

## Structure
- `install.sh`: The main automated deployment script.
- `plugins/global_auto_heal/`: The auto-heal plugin for configuration resilience.