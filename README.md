# Hermes Agent 无状态微内核架构补丁 (Hermes V2 Microkernel)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

这是一个针对 [Hermes Agent](https://github.com/NousResearch/hermes-agent) 用户量身定制的“一键优化补丁包”。

本补丁的核心目标只有一个：**极致节省 Token 消耗，确保每一次主对话都在最纯净、最轻量化的状态下运行。**

## 💡 核心设计理念：按需唤醒的“微内核”机制

随着 Hermes 使用时间的增加，系统后台往往会积累大量高消耗资源（如复杂的代码工具、浏览器控制等 MCP 节点）以及许多并不常用的冗余技能（Skills）。如果这些重型外挂长时间驻留主干网络，就会导致每一次简单的日常对话都背负着庞大的上下文负载，疯狂燃烧 Token 费用。

为了解决这个问题，本架构引入了以下核心机制：

1. **冷库化管理 (Cold Storage)**
   将所有非日常高频使用的重型 Skills 统一放逐至冷库 (`~/.hermes/skills_archive/`)。主节点仅保留通讯规范、微内核维护等“骨架级”常驻记忆。
   
2. **重型工具“子代理”隔离 (Sub-Agent Offloading)**
   将高耗能的 MCP 工具（如 Minimax、Chrome DevTools）与主会话剥离，默认强制关闭 (`enabled: false`)。取而代之的是采用名为 `heavy-tool-subagent` 的子代理策略。当需要进行代码编写或复杂任务时，再通过专属环境（如附带 `HERMES_HEAL=0` 参数）进行瞬间唤醒与挂载。

3. **终端毫秒级净空拦截器 (Auto-Heal Wrapper)**
   为了防止突然断电或报错导致工具卡在“开启”状态，补丁在 `~/.bashrc` 中注入了高智商拦截器。每当你敲下 `hermes chat` 开始新的沟通，它会在毫秒之间自动为你清空所有被污染的状态，强制阻断重型 MCP 节点的启动。

4. **全平台核心生命周期阻断插件 (Global Auto-Heal Plugin) [NEW]**
   单纯的 Bash 拦截器无法覆盖 Web UI 或 Telegram 等跨端通讯方式。为了实现真正意义上全平台级别的“阅后即焚”与 0 污染，本补丁利用 Hermes 原生 Python 插件机制，直接 Hook 了底层生命周期（`on_session_start`、`on_session_end` 等），强制确保无论从哪个平台发起或结束会话，重型节点都被死死锁在休眠状态。

**最终结果：** 主会话 Token 消耗断崖式下降，环境彻底实现跨全平台的“0污染”，且具备物理级的凭据安全隔离。

---

## 🛠️ 如何安装？（极简部署）

## Installation

1. Clone the repository and run the installation script:
```bash
git clone https://github.com/Inmanager/hermes-v2-microkernel.git
cd hermes-v2-microkernel
./install.sh
```

2. **Crucial Configuration for Auto-Heal Mechanism**: The V2 microkernel blocks heavy MCP servers during generic CLI tasks to save tokens and maintain a clean context. **You must define which MCP servers are considered "heavy" in your environment.**
Add the `HERMES_HEAVY_MCPS` environment variable to your shell configuration file (e.g., `~/.bashrc` or `~/.zshrc`). It should be a comma-separated list of the tool names.
```bash
export HERMES_HEAVY_MCPS="minimax,chrome-devtools,puppeteer"
```
If you do not set this variable, the Auto-Heal mechanism will safely bypass interception and assume no tools need to be blocked, avoiding disruption to normal users.

**第三步：刷新你的终端让补丁生效**
```bash
source ~/.bashrc
```

---

## 🎮 怎么使用这些“被隔离”的重型工具？

在需要让 AI 写代码或处理重度任务时，只需要在唤醒命令前加上临时通行证 `HERMES_HEAL=0`，系统就会解除拦截器，允许重型节点全面爆发：

```bash
HERMES_HEAL=0 hermes chat -q "帮我写一段复杂的贪吃蛇代码并运行"
```

---

## 🔄 架构自我维护与升级决策

由于 Hermes 官方本体处于快速迭代中，用户必然会担忧：**官方更新后，这个微内核架构是否会产生冲突？未来如何维护？**

为了保证本架构的生命力，安装包内自带了一个名为 `microkernel-maintenance`（微内核架构维护）的**反编译评审技能 (Skill)**。

**当 Hermes 执行官方更新后，你只需要输入以下命令：**
```bash
hermes chat -q "启动 microkernel-maintenance 架构检查"
```

AI 将自动调取官方的最新变更日志，对比当前系统内的“拦截器脚本”、“子代理模式”与官方的新特性。它会帮你做出以下高阶决策：
1. **自动修复**：如果官方变更了路径或格式，AI 将自动向本架构生成修复补丁。
2. **优劣对比**：如果官方原生支持了“按需调用 MCP”的功能，AI 将对比官方方案与本架构方案谁更省 Token、谁更安全。
3. **架构终止 (Deprecation)**：如果官方方案已达到完美级别，AI 会提示并协助你卸载微内核补丁，完成向官方版本的无缝回归。

这就是本项目的终极理念：**以优雅的姿态优化当下，以体面的方式迎接未来。**

---

## 📄 许可证
MIT License