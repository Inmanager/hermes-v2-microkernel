# Hermes V2 Microkernel

[English](README.md) | [中文版](README_zh.md)

Hermes V2 Microkernel is a lightweight, secure, and resilient architecture designed for Hermes Agent. It provides robust environmental protection, global auto-healing, and optimized configuration management to ensure a stable agent environment.

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