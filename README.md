# AI 智能体系统 · 一键安装入口

4 个开箱即用的 AI 智能体,跑在您的电脑上,通过 Claude Code(VSCode 插件)使用。

- 🏗️ **独立站建站智能体** — 2-3 天交付一个 B2B 询盘型外贸独立站
- 📊 **网站运营智能体** — 每日巡检 / 月报 / SEO / GEO 全自动
- 🧩 **12 个 MCP 服务** — 支撑上面两个智能体的自动化工具
- 🎨 **Astro B2B 起点模板** — 建站基础模板

---

## 🚀 一键安装

**先装这几个**(都免费):

1. **VSCode**: <https://code.visualstudio.com>
2. **Node.js 20+**: <https://nodejs.org>(下 LTS 版)
3. **Claude Code 插件**: VSCode 扩展市场搜 `Claude Code`
4. **Claude 订阅**: <https://claude.ai>,买 Pro($20/月)

**然后在 VSCode 打开终端**(Mac 按 `⌃` + `` ` ``,Windows/Linux 按 `Ctrl + ~`),**粘这一行回车**:

```bash
curl -fsSL https://raw.githubusercontent.com/beikeint/ai-agents-onboarding/main/onboarding.sh | bash
```

等 5-10 分钟,看到 `🎉 安装完成` 就行。

---

## 📖 装完怎么用

```bash
code ~/ai-agents/web-ops
```

VSCode 打开后按 `Ctrl + Esc`(Mac 是 `⌃ + Esc`)打开 Claude Code 面板,输入:

```
你好,请读 CLAUDE.md 介绍你自己
```

智能体会告诉您它能做什么。

### 4 个智能体入口

| 智能体 | 什么时候用 | 一句话上手 |
|---|---|---|
| `~/ai-agents/web-ops` | 已经有网站,要做运营 | `今日任务` / `今日巡检` |
| `~/ai-agents/site-builder` | 要从 0 做一个新站 | `启动建站` |
| `~/ai-agents/astro-b2b-starter` | 建站的起点代码 | 由 site-builder 自动 fork |
| `~/ai-agents/mcp-servers` | 上面三个的自动化底座 | 不用直接打开,会自动被调用 |

每个智能体根部都有 `GETTING_STARTED.md`,5 分钟读完就懂。

---

## 🔄 获取更新

智能体持续升级。拿最新:

```bash
cd ~/ai-agents/web-ops && git pull
cd ~/ai-agents/site-builder && git pull
cd ~/ai-agents/mcp-servers && git pull
cd ~/ai-agents/astro-b2b-starter && git pull
```

---

## ❓ 常见问题

**Q:安装脚本报错 "Node.js 太旧"?**
A:您的 Node 版本低于 20。去 <https://nodejs.org> 下最新 LTS 版重装。

**Q:`curl` 超时或失败?**
A:换个网络试(手机热点通常最稳),或者联系服务商。

**Q:装完 Claude Code 面板里看不到智能体效果?**
A:可能 MCP 没配好。联系服务商远程协助配 `~/.claude/mcp.json` 和各智能体的 `.env`。

**Q:我能改智能体吗?**
A:可以,但**只改 `.env` 和 `.claude/settings.local.json`**。改 CLAUDE.md 或 skills 会导致以后 `git pull` 冲突。要深度定制的 fork 一份自己维护。

**Q:我不想让别人看到我的使用情况?**
A:智能体**跑在您自己电脑上**,产生的客户数据、分析报告、客户站配置都在您本机,服务商看不到(除非您主动发给他)。

---

## 🆘 遇到问题

联系您的服务商:

- 微信响应(工作时间)
- 远程协助(向日葵 / ToDesk / 飞书)
- 紧急修复

---

## 📜 开源许可

这 4 个 repo 是**公开**的。您可以自由阅读、学习、fork,但不提供任何担保。

自用、内部使用、改造、商用均可。商用请保留"基于 AI 智能体系统"的署名。

---

<details>
<summary>🔧 服务商/开发者扩展说明(点开展开)</summary>

### 如何给自己的客户交付

1. 告诉客户上面的"一键安装"命令(完全 self-service,不需要配 Deploy Key 等)
2. 客户装完后,远程帮他配:
   - `~/.claude/mcp.json` 注册 MCP
   - 每个智能体的 `.env`(API Key 等)
3. 教客户打第一句对话(如 `今日巡检`)

### 发现 bug / 想贡献?

开 issue 或 PR 到对应 repo 即可。

### 自己维护一个衍生版?

fork 4 个 repo 到您自己的 GitHub,改 `onboarding.sh` 里的 `GH_USER` 为您的用户名即可。

</details>
