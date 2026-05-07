# Hermes Agent V2 Microkernel Architecture

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

> **"极致的性能源于纯粹的安全与隔离。"** (Extreme performance stems from pure security and isolation.)

这是一个针对 [Hermes Agent](https://github.com/NousResearch/hermes-agent) 的“极客级”魔改底层配置架构（V2 微内核）。它由 AI 和人类经过十二轮“红蓝对抗”式的极限推演打磨而成。

## 🌟 核心特性 (Features)

### 1. 量子级防污染机制 (Auto-Heal Wrapper)
当你敲击 `hermes chat` 时，系统底层的 Bash 解析器会以毫秒级的速度智能静默拦截，清理掉所有因断电、强杀等意外遗留的高耗能工具（MCP）状态，确保每一次会话都在 0 污染的微内核下启动。
- **0 误杀率**：内置与 Python argparse 同等级别的微型位置参数解析器，完美绕过带有 `-m` 等参数旗标的假命令。
- **UX 无感知**：重定向剥离了所有校验回显输出，真正的“幽灵刺客”。

### 2. 最小权限桥接 (Secure MCP Bridge)
彻底废除了使用 `source ~/.env` 为子代理（Subagent）透传凭据的安全灾难。
- **RCE 免疫**：采用纯正则 (`grep + sed`) 静默清洗并提取凭据，即使复制了包含恶意 `rm -rf` 注入的 `.env` 文本，也不会引发底层 Bash 代码的任意执行！
- **401 容错**：通过强大的 `printf + sed` 去除不可见的单双引号与首尾隐形空格，完美防御 `xargs` 对转义符的致命吞噬。

### 3. 深空记忆锁定 (Memory Context Optimization)
把 Hermes 的记忆压缩算法微调至最优黄金分割：
- `target_ratio: 0.5`
- `threshold: 0.03`

### 4. 逻辑悖论解环 (Bypass Mechanism)
内置 `$HERMES_HEAL` 环境变量。如果你需要人工启动重型工具并开启主会话，只需输入 `HERMES_HEAL=0 hermes chat` 即可完美绕过自愈防线。

## 🚀 安装 (Installation)

```bash
git clone https://github.com/your-username/hermes-v2-microkernel.git
cd hermes-v2-microkernel
chmod +x install.sh
./install.sh
```

重新加载终端：
```bash
source ~/.bashrc
```

## 🛠 原理与架构 (Architecture)
微内核的本质在于**“冷热分离”**与**“子代理降权”**：
主核心 `hermes chat` 始终保持绝对轻量，不再驻留庞大的浏览器插件（Puppeteer）与代码工作流（Minimax MCP）。只有当触发 `heavy-tool-subagent` 技能时，系统才会通过我们的桥接安全沙盒临时接管控制权。

## 📄 许可证 (License)
MIT
