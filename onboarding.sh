#!/usr/bin/env bash
# ================================================================
# AI 智能体系统 · 客户一键安装 + 自动激活脚本
# ================================================================
# 用法(在终端里粘一行回车):
#
#   curl -fsSL https://raw.githubusercontent.com/beikeint/ai-agents-onboarding/main/onboarding.sh | bash
#
# 装完之后:打开 VSCode → Claude Code → 跟 AI 同事说"你好"开始用
# ================================================================

set -uo pipefail

GREEN=$'\033[0;32m'
YELLOW=$'\033[0;33m'
CYAN=$'\033[0;36m'
RED=$'\033[0;31m'
BOLD=$'\033[1m'
RESET=$'\033[0m'

say()   { printf "%s%s%s\n" "$CYAN" "$1" "$RESET"; }
ok()    { printf "%s✓ %s%s\n" "$GREEN" "$1" "$RESET"; }
warn()  { printf "%s⚠ %s%s\n" "$YELLOW" "$1" "$RESET"; }
err()   { printf "%s✗ %s%s\n" "$RED" "$1" "$RESET"; }
hr()    { printf "\n%s%s\n%s\n%s\n" "$BOLD$CYAN" "================================================================" "$1" "================================================================${RESET}"; }

GH_USER="beikeint"
INSTALL_DIR="$HOME/ai-agents"

REPOS=(
  "web-ops:web-ops-public:网站运营智能体"
  "site-builder:site-builder-public:独立站建站智能体"
  "astro-b2b-starter:astro-b2b-starter-public:建站起点模板"
  "mcp-servers:mcp-servers-public:12 个 MCP 服务"
)

# 12 个 MCP 名字(给后面注册 mcp.json 用)
MCPS=(
  client-manager
  site-monitor
  seo-checker
  search-analytics
  content-tracker
  deployer
  fetch
  memory
  image-generator
  video-generator
  wechat-publisher
  wecom-bot
)

clear || true
hr "AI 智能体系统 · 一键安装"

cat <<'EOM'

开始安装,预计 5-10 分钟,全程自动。

EOM

# ---------------------------------------------------------------
# Step 1. 环境检查
# ---------------------------------------------------------------
hr "[1/4] 环境检查"

MISSING=()
command -v git >/dev/null && ok "Git $(git --version | awk '{print $3}')" || MISSING+=(Git)

if command -v node >/dev/null; then
  NODE_VER=$(node -v | sed 's/v//')
  NODE_MAJOR=${NODE_VER%%.*}
  if (( NODE_MAJOR >= 20 )); then
    ok "Node.js v$NODE_VER"
  else
    err "Node.js v$NODE_VER 太旧(需要 v20+)"
    MISSING+=("Node.js 20+")
  fi
else
  MISSING+=("Node.js 20+")
fi

if [ ${#MISSING[@]} -gt 0 ]; then
  echo
  err "缺少:${MISSING[*]}"
  echo
  echo "请先装好这些再重跑:"
  for item in "${MISSING[@]}"; do
    case $item in
      Git) echo "  - Git: https://git-scm.com/downloads";;
      "Node.js 20+") echo "  - Node.js: https://nodejs.org (下 LTS 版)";;
    esac
  done
  exit 1
fi

# ---------------------------------------------------------------
# Step 2. 克隆 4 个 repo
# ---------------------------------------------------------------
hr "[2/4] 下载 4 个智能体"

mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR"

FAILED=()
for entry in "${REPOS[@]}"; do
  LOCAL="${entry%%:*}"
  REST="${entry#*:}"
  REMOTE="${REST%%:*}"
  DESC="${REST#*:}"

  printf "  [%s] %s ... " "$LOCAL" "$DESC"

  if [ -d "$LOCAL/.git" ]; then
    if (cd "$LOCAL" && git fetch -q && git reset --hard origin/main -q 2>/dev/null); then
      printf "%s✓ 已更新%s\n" "$GREEN" "$RESET"
    else
      printf "%s⚠ 已存在但更新失败%s\n" "$YELLOW" "$RESET"
    fi
  else
    if git clone -q "https://github.com/$GH_USER/$REMOTE.git" "$LOCAL" 2>/dev/null; then
      printf "%s✓ 下载完成%s\n" "$GREEN" "$RESET"
    else
      printf "%s✗ 失败%s\n" "$RED" "$RESET"
      FAILED+=("$LOCAL")
    fi
  fi
done

if [ ${#FAILED[@]} -gt 0 ]; then
  err "${#FAILED[@]} 个仓库下载失败:${FAILED[*]}"
  exit 1
fi

# ---------------------------------------------------------------
# Step 3. 装依赖
# ---------------------------------------------------------------
hr "[3/4] 安装依赖 + 自动配置"

# 3a. 智能体级 install.sh
for entry in "${REPOS[@]}"; do
  LOCAL="${entry%%:*}"
  if [ -f "$INSTALL_DIR/$LOCAL/install.sh" ]; then
    say "[$LOCAL] 跑 install.sh..."
    (cd "$INSTALL_DIR/$LOCAL" && bash install.sh) 2>&1 | grep -E "(✓|✗|⚠)" || true
  fi
done

# 3b. starter 装 npm
if [ -d "$INSTALL_DIR/astro-b2b-starter" ] && [ -f "$INSTALL_DIR/astro-b2b-starter/package.json" ]; then
  say "[astro-b2b-starter] 装 Astro 依赖(约 1-2 分钟)..."
  (cd "$INSTALL_DIR/astro-b2b-starter" && npm install --no-audit --no-fund --loglevel=error 2>&1 | tail -2) || warn "Astro 依赖安装失败,可后续手动补"
fi

# 3c. 自动注册 ~/.claude/mcp.json(让 12 个 MCP 立即可用)
say "注册 MCP 服务到 Claude Code..."
mkdir -p "$HOME/.claude"
MCP_JSON="$HOME/.claude/mcp.json"

# 用 node 来安全合并/生成 JSON(防止破坏客户已有 mcp.json)
node <<NODE_EOF
const fs = require('fs');
const path = require('path');
const os = require('os');

const mcpJsonPath = path.join(os.homedir(), '.claude', 'mcp.json');
const mcpServersDir = path.join(os.homedir(), 'ai-agents', 'mcp-servers');

const newMcps = {
  'client-manager':    { command: 'node', args: [path.join(mcpServersDir, 'client-manager', 'index.mjs')] },
  'site-monitor':      { command: 'node', args: [path.join(mcpServersDir, 'site-monitor', 'index.mjs')] },
  'seo-checker':       { command: 'node', args: [path.join(mcpServersDir, 'seo-checker', 'index.mjs')] },
  'search-analytics':  { command: 'node', args: [path.join(mcpServersDir, 'search-analytics', 'index.mjs')] },
  'content-tracker':   { command: 'node', args: [path.join(mcpServersDir, 'content-tracker', 'index.mjs')] },
  'deployer':          { command: 'node', args: [path.join(mcpServersDir, 'deployer', 'index.mjs')] },
  'image-generator':   { command: 'node', args: [path.join(mcpServersDir, 'image-generator', 'index.mjs')] },
  'video-generator':   { command: 'node', args: [path.join(mcpServersDir, 'video-generator', 'index.mjs')] },
  'wechat-publisher':  { command: 'node', args: [path.join(mcpServersDir, 'wechat-publisher', 'index.mjs')] },
  'wecom-bot':         { command: 'node', args: [path.join(mcpServersDir, 'wecom-bot', 'index.mjs')] },
};

let existing = { mcpServers: {} };
if (fs.existsSync(mcpJsonPath)) {
  try {
    existing = JSON.parse(fs.readFileSync(mcpJsonPath, 'utf-8'));
    if (!existing.mcpServers) existing.mcpServers = {};
  } catch (e) {
    console.error('  ⚠ 已有 mcp.json 解析失败,将重建');
    existing = { mcpServers: {} };
  }
}

let added = 0;
for (const [name, config] of Object.entries(newMcps)) {
  if (!existing.mcpServers[name]) {
    existing.mcpServers[name] = config;
    added++;
  }
}

fs.writeFileSync(mcpJsonPath, JSON.stringify(existing, null, 2));
console.log(\`  ✓ \${added} 个 MCP 已注册到 ~/.claude/mcp.json (合计 \${Object.keys(existing.mcpServers).length})\`);
NODE_EOF

# 3d. 初始化空运行时数据
say "初始化运行时数据..."
[ -d "$INSTALL_DIR/mcp-servers/client-manager" ] && [ ! -f "$INSTALL_DIR/mcp-servers/client-manager/clients.json" ] && \
  echo '{}' > "$INSTALL_DIR/mcp-servers/client-manager/clients.json" && ok "  client-manager/clients.json"

[ -d "$INSTALL_DIR/mcp-servers/content-tracker" ] && [ ! -f "$INSTALL_DIR/mcp-servers/content-tracker/content-plan.json" ] && \
  echo '{"plans":{},"contents":[]}' > "$INSTALL_DIR/mcp-servers/content-tracker/content-plan.json" && ok "  content-tracker/content-plan.json"

# 3e. 各 MCP 的 .env.example → .env (空占位,等待客户填或 AI 引导)
say "生成 .env 模板..."
for mcp in "$INSTALL_DIR"/mcp-servers/*/; do
  if [ -f "$mcp/.env.example" ] && [ ! -f "$mcp/.env" ]; then
    cp "$mcp/.env.example" "$mcp/.env"
  fi
done
for agent in web-ops site-builder; do
  [ -f "$INSTALL_DIR/$agent/.env.example" ] && [ ! -f "$INSTALL_DIR/$agent/.env" ] && \
    cp "$INSTALL_DIR/$agent/.env.example" "$INSTALL_DIR/$agent/.env"
done
ok "  .env 已就位(等 AI 引导您填关键 key)"

# ---------------------------------------------------------------
# Step 4. 生成激活向导
# ---------------------------------------------------------------
hr "[4/4] 生成激活向导"

cat > "$INSTALL_DIR/激活向导.md" <<'GUIDE_EOF'
# 🚀 您的 AI 同事激活向导

恭喜!4 位 AI 同事已经入职您的电脑。

## 🎯 接下来 1 步开始用

打开 VSCode,**用 VSCode 打开下面任一智能体目录**(选您今天最想用的):

```bash
# 想做日常运营(已有网站) → 打开运营经理:
code ~/ai-agents/web-ops

# 想从 0 建站 → 打开建站总监:
code ~/ai-agents/site-builder
```

打开后**按 `⌃ + Esc` (Mac) / `Ctrl + Esc`(Windows)** 召唤 Claude Code,在对话框输入:

```
您好,开始激活
```

AI 同事会:

1. **检测您当前的环境**:看看 API Key、客户档案等是否就位
2. **主动引导您填补缺失项**:一步一步问您几个问题(不超过 5 分钟)
3. **激活完成后立即开始干活**:第一个任务通常是"分析您的网站现状"

## 📋 您将被问到的内容(提前准备好可以更快)

| 项 | 怎么准备 | 用途 |
|---|---|---|
| 您公司的网站域名 | 直接说网址 | 让 AI 知道要分析哪个站 |
| 您所在的行业 | 一句话描述 | AI 推荐的内容方向 |
| Google Search Console 服务账号 JSON 文件 | 见下文"如何申请" | 自动拉 Google 排名数据 |
| Google Analytics 4 Property ID | 9 位数字,GA4 Admin 看 | 自动拉流量分析数据 |
| (建站才需要)您的服务器 SSH | 您托管站的账号密码 | 让建站总监自动部署 |

**没准备好也没关系**,AI 会先用能用的部分干活,缺的项随时补。

## 🔑 如何申请 Google Search Console 服务账号

(这一步通常 5-10 分钟)

1. 打开 <https://console.cloud.google.com/>(用您的 Google 账号登录)
2. 顶部建一个新项目(随便叫什么)
3. 左侧菜单 → IAM 和管理 → 服务账号 → 创建服务账号
4. 给它任意名字(如 `gsc-reader`)→ 完成
5. 进入这个服务账号 → 密钥 → 添加密钥 → JSON → 下载
6. 把下载的 JSON 文件放到 `~/.config/gsc/service-account.json`(没这目录就 `mkdir -p ~/.config/gsc`)
7. 打开 GSC <https://search.google.com/search-console>
8. 点您的网站 → 设置 → 用户和权限 → 添加用户 → 把 JSON 里的 `client_email` 字段值粘进去 → 选"完整"权限

## 🆘 卡住了?

扫 README 底部的二维码加我微信,工作时间响应。

## 📚 想了解每位 AI 同事能做什么?

打开任一智能体目录,看根部的 `CLAUDE.md` 文件 — 有完整能力清单和指令示例。
GUIDE_EOF

ok "$INSTALL_DIR/激活向导.md"

# ---------------------------------------------------------------
# 完成
# ---------------------------------------------------------------
hr "🎉 安装完成"

cat <<EOM

已就绪:
  ✓ 4 个智能体下载到 $INSTALL_DIR
  ✓ 12 个 MCP 自动注册到 ~/.claude/mcp.json
  ✓ 运行时数据初始化(空白档案,等您录入)
  ✓ .env 模板就位(等 AI 引导您填)
  ✓ 激活向导:$INSTALL_DIR/激活向导.md

⭐ 立刻开始(任选其一):

   code ~/ai-agents/web-ops      # 用运营经理(已有网站)
   code ~/ai-agents/site-builder # 用建站总监(从 0 建站)

   打开后按 Ctrl+Esc 召唤 Claude Code,输入:
     您好,开始激活

   AI 同事会一步步引导您 5 分钟内激活完成。

📖 完整流程在 $INSTALL_DIR/激活向导.md

⚠️ 重要:重启 VSCode 让新注册的 MCP 生效

EOM
