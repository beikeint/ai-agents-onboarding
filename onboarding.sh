#!/usr/bin/env bash
# ================================================================
# AI 智能体系统 · 客户一键上手脚本
# ================================================================
# 用法:bash onboarding.sh
# 或:  curl -sL https://raw.githubusercontent.com/beikeint/ai-agents-onboarding/main/onboarding.sh | bash
# ================================================================

set -uo pipefail

# 颜色
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
hr()    { printf "%s%s\n%s\n%s\n" "$BOLD" "================================================================" "$1" "================================================================${RESET}"; }
pause() { printf "\n%s按回车继续 ↵ %s" "$YELLOW" "$RESET"; read -r _; }

clear || true

hr "AI 智能体系统 · 一键安装"

cat <<'EOM'

欢迎!这个脚本会帮您完成:

  1) 检查您电脑上的环境(Node / Git / VSCode / Claude Code)
  2) 为您生成一把专属密钥(SSH Key,用于访问智能体代码仓库)
  3) 引导您把公钥发给服务商,等对方配好访问权限
  4) 自动下载 4 个智能体仓库
  5) 自动安装所有依赖

全程约 15-30 分钟,中途有 1 次需要等服务商配置(约 1-3 分钟)。

如果任何一步卡住,请把屏幕截图发给服务商,不要盲目重试。

EOM
pause

# ---------------------------------------------------------------
# Step 1. 环境检查
# ---------------------------------------------------------------
hr "Step 1/5 · 环境检查"

NEED_INSTALL=()

if command -v git >/dev/null; then
  ok "Git $(git --version | awk '{print $3}')"
else
  err "未装 Git"; NEED_INSTALL+=(git)
fi

if command -v node >/dev/null; then
  NODE_VER=$(node -v | sed 's/v//')
  NODE_MAJOR=${NODE_VER%%.*}
  if (( NODE_MAJOR >= 20 )); then
    ok "Node.js v$NODE_VER"
  else
    err "Node.js v$NODE_VER 太旧,需要 v20+"; NEED_INSTALL+=(node20)
  fi
else
  err "未装 Node.js"; NEED_INSTALL+=(node20)
fi

if command -v code >/dev/null; then
  ok "VSCode 已装"
else
  warn "未装 VSCode(可稍后补装,不影响本次)"
fi

if command -v claude >/dev/null 2>&1; then
  ok "Claude Code CLI 已装"
else
  warn "未检测到 Claude Code CLI(VSCode 插件版也可以,稍后去扩展商店搜 'Claude Code')"
fi

if [ ${#NEED_INSTALL[@]} -gt 0 ]; then
  echo
  err "缺少必需环境:${NEED_INSTALL[*]}"
  echo
  echo "请先安装:"
  for item in "${NEED_INSTALL[@]}"; do
    case $item in
      git) echo "  - Git: https://git-scm.com/downloads";;
      node20) echo "  - Node.js 20+: https://nodejs.org(下 LTS 版本即可)";;
    esac
  done
  echo
  echo "装完后重新跑本脚本。"
  exit 1
fi

echo
ok "环境检查通过"
pause

# ---------------------------------------------------------------
# Step 2. 生成 SSH Key
# ---------------------------------------------------------------
hr "Step 2/5 · 生成专属密钥"

KEY_PATH="$HOME/.ssh/id_ai_agent"
mkdir -p "$HOME/.ssh" && chmod 700 "$HOME/.ssh"

if [ -f "$KEY_PATH" ]; then
  warn "已存在一把 AI 智能体密钥($KEY_PATH)"
  read -p "重新生成会覆盖。是否保留现有的并继续? [Y/n] " yn
  if [[ ! $yn =~ ^[Nn]$ ]]; then
    ok "保留现有密钥"
  else
    rm -f "$KEY_PATH" "$KEY_PATH.pub"
    ssh-keygen -t ed25519 -f "$KEY_PATH" -N "" -C "ai-agent-$(hostname)-$(date +%Y%m%d)" -q
    ok "已生成新密钥"
  fi
else
  say "正在生成 ed25519 密钥(1-2 秒)..."
  ssh-keygen -t ed25519 -f "$KEY_PATH" -N "" -C "ai-agent-$(hostname)-$(date +%Y%m%d)" -q
  ok "已生成密钥: $KEY_PATH"
fi

# 配 SSH config
SSH_CONFIG="$HOME/.ssh/config"
if ! grep -q "Host github-ai-agent" "$SSH_CONFIG" 2>/dev/null; then
  cat >> "$SSH_CONFIG" <<EOF

# AI 智能体专用(由 onboarding.sh 添加)
Host github-ai-agent
  HostName github.com
  User git
  IdentityFile $KEY_PATH
  IdentitiesOnly yes
EOF
  chmod 600 "$SSH_CONFIG"
  ok "SSH 配置已更新"
else
  ok "SSH 配置已存在,跳过"
fi

echo
pause

# ---------------------------------------------------------------
# Step 3. 把公钥发给服务商
# ---------------------------------------------------------------
hr "Step 3/5 · 把公钥发给服务商"

cat <<'EOM'

下面这串字符是您的"公钥",请把它完整复制发给服务商(微信/邮件都行)。

⚠️ 不是私钥,可以放心发。私钥(id_ai_agent)永远不要发给任何人!

复制方法:
  - 鼠标从第一行 "ssh-ed25519" 开始选到最后一行结束
  - Ctrl+Shift+C (终端里的复制)或右键复制
  - 粘到微信/邮件发给服务商

═══════════════════════════════ 您的公钥 ═══════════════════════════════
EOM
cat "$KEY_PATH.pub"
echo "═══════════════════════════════════════════════════════════════════════"
echo

cat <<'EOM'

接下来:
  1) 把上面公钥发给服务商
  2) 等待服务商回复"已配好"(通常 1-3 分钟)
  3) 收到回复后按回车继续

EOM
pause

# ---------------------------------------------------------------
# Step 4. 克隆 4 个仓库
# ---------------------------------------------------------------
hr "Step 4/5 · 下载 4 个智能体"

INSTALL_DIR="$HOME/ai-agents"
mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR"

REPOS=(
  "web-ops:web-ops-public:网站运营智能体"
  "site-builder:site-builder-public:独立站建站智能体"
  "astro-b2b-starter:astro-b2b-starter-public:建站起点模板"
  "mcp-servers:mcp-servers-public:12 个 MCP 服务"
)

GH_USER="beikeint"
FAILED_REPOS=()

for entry in "${REPOS[@]}"; do
  LOCAL="${entry%%:*}"
  REST="${entry#*:}"
  REMOTE="${REST%%:*}"
  DESC="${REST#*:}"

  say "[$LOCAL] ($DESC) 下载中..."

  if [ -d "$LOCAL/.git" ]; then
    (cd "$LOCAL" && git pull -q) && ok "[$LOCAL] 已存在,拉取最新" || warn "[$LOCAL] 拉取失败"
  else
    if git clone -q "git@github-ai-agent:$GH_USER/$REMOTE.git" "$LOCAL" 2>/dev/null; then
      ok "[$LOCAL] 克隆成功"
    else
      err "[$LOCAL] 克隆失败"
      FAILED_REPOS+=("$LOCAL")
    fi
  fi
done

if [ ${#FAILED_REPOS[@]} -gt 0 ]; then
  echo
  err "有 ${#FAILED_REPOS[@]} 个仓库下载失败"
  echo
  echo "最常见原因:服务商还没配好您的访问权限。"
  echo "解决:再等 1-2 分钟,然后重新跑本脚本。"
  echo
  echo "如果多次失败,把屏幕截图发给服务商。"
  exit 1
fi

echo
ok "4 个仓库已全部下载到 $INSTALL_DIR"
ls -la "$INSTALL_DIR" | grep ^d | awk '{print "  "$NF}' | grep -v "^\s*\.\s*$"
pause

# ---------------------------------------------------------------
# Step 5. 安装依赖
# ---------------------------------------------------------------
hr "Step 5/5 · 安装依赖"

for entry in "${REPOS[@]}"; do
  LOCAL="${entry%%:*}"
  if [ -f "$INSTALL_DIR/$LOCAL/install.sh" ]; then
    say "[$LOCAL] 跑 install.sh..."
    (cd "$INSTALL_DIR/$LOCAL" && bash install.sh) || warn "[$LOCAL] install.sh 报错(可稍后找服务商处理)"
    echo
  fi
done

# starter 单独装 npm
if [ -d "$INSTALL_DIR/astro-b2b-starter" ] && [ -f "$INSTALL_DIR/astro-b2b-starter/package.json" ]; then
  say "[astro-b2b-starter] 装 Astro 依赖(约 1-2 分钟)..."
  (cd "$INSTALL_DIR/astro-b2b-starter" && npm install --no-audit --no-fund --loglevel=error 2>&1 | tail -3) || warn "依赖安装失败"
fi

echo
ok "所有依赖已装完"
pause

# ---------------------------------------------------------------
# 完成
# ---------------------------------------------------------------
hr "🎉 安装完成"

cat <<EOM

安装位置:$INSTALL_DIR

接下来:

  1) 用 VSCode 打开其中一个智能体(从这个开始推荐 web-ops)
     在终端跑:  code ~/ai-agents/web-ops

  2) 打开 Claude Code 面板(侧边栏 Claude 图标 / 按 Ctrl+Esc)

  3) 对话框输入:
       你好,请读 CLAUDE.md 介绍你自己

  4) 如果智能体不能正常工作(比如找不到 MCP),联系服务商帮您配:
     - ~/.claude/mcp.json (MCP 服务注册)
     - 各智能体下的 .env (API Key)

常见入口文档:
  - 每个智能体根部的 GETTING_STARTED.md(上手指南)
  - 每个智能体的 CLAUDE.md(能力定义)

祝您用得顺!

EOM
