#!/usr/bin/env bash
# ================================================================
# AI 智能体系统 · 客户一键安装脚本
# ================================================================
# 用法(在终端里粘一行回车):
#
#   curl -fsSL https://raw.githubusercontent.com/beikeint/ai-agents-onboarding/main/onboarding.sh | bash
#
# 无需任何账号授权、无需生成密钥、无需等待。全程自动。
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

clear || true
hr "AI 智能体系统 · 一键安装"

cat <<'EOM'

开始安装,预计 5-10 分钟,全程自动,您只需要等待。

EOM

# ---------------------------------------------------------------
# Step 1. 环境检查
# ---------------------------------------------------------------
hr "[1/3] 环境检查"

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
  echo
  exit 1
fi

# ---------------------------------------------------------------
# Step 2. 克隆 4 个 repo
# ---------------------------------------------------------------
hr "[2/3] 下载 4 个智能体"

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
    if (cd "$LOCAL" && git pull -q 2>/dev/null); then
      printf "%s✓ 已更新%s\n" "$GREEN" "$RESET"
    else
      printf "%s⚠ 已存在但 pull 失败%s\n" "$YELLOW" "$RESET"
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
  echo
  err "${#FAILED[@]} 个仓库下载失败:${FAILED[*]}"
  echo "可能是网络问题,请检查网络后重跑本脚本。"
  exit 1
fi

# ---------------------------------------------------------------
# Step 3. 装依赖
# ---------------------------------------------------------------
hr "[3/3] 安装依赖"

for entry in "${REPOS[@]}"; do
  LOCAL="${entry%%:*}"
  if [ -f "$INSTALL_DIR/$LOCAL/install.sh" ]; then
    say "[$LOCAL] 跑 install.sh..."
    (cd "$INSTALL_DIR/$LOCAL" && bash install.sh) 2>&1 | grep -E "(✓|✗|⚠)" || true
    echo
  fi
done

# starter 额外装 npm(因为它没 install.sh,是标准 Astro 项目)
if [ -d "$INSTALL_DIR/astro-b2b-starter" ] && [ -f "$INSTALL_DIR/astro-b2b-starter/package.json" ]; then
  say "[astro-b2b-starter] 装 Astro 依赖(约 1-2 分钟)..."
  (cd "$INSTALL_DIR/astro-b2b-starter" && npm install --no-audit --no-fund --loglevel=error 2>&1 | tail -2) || warn "依赖安装失败,可以以后手动补装"
fi

# ---------------------------------------------------------------
# 完成
# ---------------------------------------------------------------
hr "🎉 安装完成"

cat <<EOM

安装位置:$INSTALL_DIR

接下来 2 步开始用:

  1) 用 VSCode 打开 web-ops 智能体
     在终端跑:  code ~/ai-agents/web-ops

  2) 按 Ctrl+Esc (Mac 是 Control+Esc) 打开 Claude Code 面板
     输入:  你好,请读 CLAUDE.md 介绍你自己

智能体会告诉您它能做什么。

需要进一步配置 API Key 或 MCP 的,联系服务商远程帮您配。

====================================================================

使用小贴士:

  · 说中文即可,不用学命令
  · 不懂就问智能体"你能做什么"
  · 每天一句"每日巡检"就能自动跑
  · 遇到问题截图发服务商,24 小时内响应

获取更新:
  cd ~/ai-agents/web-ops && git pull
  (或其它任一智能体目录)

EOM
