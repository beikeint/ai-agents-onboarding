# AI 智能体系统 · 一键安装入口

本页给**客户**看。你是**服务商**的请看底部说明。

---

## 🎯 你将得到什么

4 个协同工作的 AI 智能体:

- 🏗️ **独立站建站智能体** — 2-3 天建一个外贸 B2B 询盘型独立站
- 📊 **网站运营智能体** — 每日巡检 + GSC/GA4 分析 + 月报 + 持续增长
- 🧩 **12 个 MCP 服务** — 支撑上面两个智能体的自动化工具
- 🎨 **Astro 建站起点模板** — 所有网站的基础模板

跑在您的电脑或服务器上,通过 Claude Code(VSCode 插件)使用。

---

## ✅ 先决条件(动手前确认)

| 项 | 要求 | 怎么得到 |
|---|---|---|
| 电脑 | macOS / Linux / Windows 11 WSL2 | - |
| Node.js | v20+ | <https://nodejs.org> 下 LTS 版本 |
| Git | 已装(Mac/Linux 通常自带) | <https://git-scm.com/downloads> |
| VSCode | 最新版 | <https://code.visualstudio.com> |
| Claude Code 插件 | 在 VSCode 里装 | VSCode → 扩展 → 搜 "Claude Code" |
| Claude 订阅 | Pro($20/月)或 Max($100/月) | <https://claude.ai> 注册 |
| 服务商联系方式 | 微信/电话 | 由服务商主动联系您 |

---

## 🚀 一键安装

**打开终端(Mac 用"终端"、Windows 用 WSL2 终端)**,跑这一行:

```bash
curl -fsSL https://raw.githubusercontent.com/beikeint/ai-agents-onboarding/main/onboarding.sh | bash
```

脚本会一步步引导您:

1. 检查环境
2. 为您生成专属密钥
3. 让您把公钥发给服务商
4. (等服务商配好,约 1-3 分钟)
5. 自动下载 4 个智能体
6. 自动安装所有依赖
7. 完成!

全程约 **15-30 分钟**。

---

## 📖 装完以后

### 第一次使用

```bash
code ~/ai-agents/web-ops
```

VSCode 打开,按 **Ctrl+Esc** 打开 Claude Code 面板,输入:

```
你好,请读 CLAUDE.md 介绍你自己
```

智能体会回应它能做的所有事。

### 阅读建议

每个智能体根部都有 **GETTING_STARTED.md**,5 分钟读完就懂怎么用。

### 获取更新

智能体持续升级。要拿最新版:

```bash
cd ~/ai-agents/web-ops && git pull
cd ~/ai-agents/site-builder && git pull
cd ~/ai-agents/mcp-servers && git pull
cd ~/ai-agents/astro-b2b-starter && git pull
```

---

## ❓ 常见问题

**Q:脚本提示"Permission denied (publickey)",什么意思?**
A:服务商还没把您发的公钥配到仓库里。再等 1-2 分钟,然后重跑本脚本。

**Q:我发了公钥,服务商说"配好了",但还是下载失败?**
A:可能有公钥粘贴不全。截图发给服务商,让他们检查。

**Q:我把 onboarding.sh 停了,要重头开始吗?**
A:不用。重跑同一条命令,脚本会检测已完成的步骤跳过,只补做还没完成的。

**Q:4 个智能体都装了,但 Claude Code 里看不到功能?**
A:可能 MCP 没配好。联系服务商远程帮您配 `~/.claude/mcp.json`。

**Q:我想只装其中一个智能体,不要全装?**
A:直接手动克隆您要的那一个即可(见 onboarding.sh 里的 git clone 命令)。

**Q:我能改这些智能体吗?**
A:可以改,但不建议直接改 CLAUDE.md 或 skills/。您应该只改 `.env` 和 `.claude/settings.local.json`,改别的会让 `git pull` 冲突。

---

## 🆘 联系服务商

遇到任何问题,联系您的服务商。一般支持:

- 电话/微信响应(工作时间)
- 远程协助(向日葵 / ToDesk / 飞书)
- 紧急修复

---

<details>
<summary>🔧 服务商说明(点开展开)</summary>

### 这个 repo 是什么

这是 4 个私有交付 repo 的**公开入口**。客户通过这个 public repo 拿到 onboarding.sh,
脚本引导客户完成"装环境 + 生密钥 + 等你配 Deploy Key + clone 4 repo + 装依赖"。

### 你作为服务商要做的

1. **签约时**:把 README 顶部的指令发给客户
2. **客户生成公钥后**:客户把公钥发微信给你
3. **把公钥配到 4 个 repo 的 Deploy Key**:

   ```bash
   PUBKEY="客户发来的公钥完整字符串"
   CLIENT_TAG="客户名-$(date +%Y%m%d)"

   for repo in web-ops-public site-builder-public astro-b2b-starter-public mcp-servers-public; do
     echo "$PUBKEY" | gh repo deploy-key add - -R beikeint/$repo -t "$CLIENT_TAG"
   done
   ```

4. **告诉客户配好了**,让他们按 onboarding.sh 里的回车继续

### 客户离开时

```bash
# 撤销某客户的 Deploy Key
for repo in web-ops-public site-builder-public astro-b2b-starter-public mcp-servers-public; do
  gh repo deploy-key list -R beikeint/$repo --json id,title \
    | jq -r '.[] | select(.title | startswith("客户名-")) | .id' \
    | xargs -I {} gh repo deploy-key delete {} -R beikeint/$repo
done
```

</details>
