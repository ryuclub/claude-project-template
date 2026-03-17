#!/bin/bash
# .claude/hooks/auto-load.sh
# 项目启动时自动从远程规范仓库下载并加载通用规范和 Skills
# 配置来自 .claude/config/claude.env 中的环境变量

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() { echo -e "${GREEN}✓${NC} $1"; }
warn() { echo -e "${YELLOW}⚠${NC} $1"; }
error() { echo -e "${RED}✗${NC} $1" >&2; }
info() { echo "  $1"; }

echo "🔄 Initializing Claude Code for this project..."

# 加载 claude.env 到当前 shell（用于后续变量替换）
CONFIG_ENV=".claude/config/claude.env"
if [ -f "$CONFIG_ENV" ]; then
  log "Loading credentials from $CONFIG_ENV"
  set -a
  source "$CONFIG_ENV"
  set +a
else
  warn "No $CONFIG_ENV found, using defaults"
fi

# 设置默认值（如果 env 中没有定义）
REMOTE_REPO="${COMMON_REPO_URL:-https://github.com/ryuclub/claude-common.git}"
CACHE_DIR="${COMMON_CACHE_DIR:-.claude/.remote-cache}"
CACHE_TTL="${COMMON_CACHE_TTL:-86400}"

CACHE_GIT="$CACHE_DIR/.git"
SYNC_FILE="$CACHE_DIR/.sync"

# 将 claude.env 持久化到 Claude Code 环境
if [ -f "$CONFIG_ENV" ] && [ -n "$CLAUDE_ENV_FILE" ]; then
  grep -v '^#' "$CONFIG_ENV" | grep -v '^$' | while read -r line; do
    echo "export $line" >> "$CLAUDE_ENV_FILE"
  done
  log "Persisted to Claude Code environment"
fi

# 检查缓存是否过期
NEED_UPDATE=true
if [ -f "$SYNC_FILE" ]; then
  LAST_SYNC=$(stat -f%m "$SYNC_FILE" 2>/dev/null || stat -c%Y "$SYNC_FILE" 2>/dev/null || echo 0)
  CURRENT_TIME=$(date +%s)
  ELAPSED=$((CURRENT_TIME - LAST_SYNC))
  HOURS_AGO=$(($ELAPSED / 3600))

  if [ $ELAPSED -lt $CACHE_TTL ]; then
    log "Cache is fresh (updated ${HOURS_AGO} hours ago)"
    NEED_UPDATE=false
  else
    warn "Cache expired (${HOURS_AGO} hours old)"
  fi
fi

# 同步或克隆 claude-common
if [ "$NEED_UPDATE" = true ]; then
  echo "📥 Syncing claude-common from GitHub..."

  if ! command -v git &> /dev/null; then
    error "git not found, cannot sync"
    [ -d "$CACHE_GIT" ] && warn "using existing cache" || error "no cache available"
  else
    # 记录日志文件路径（用于后续 clone 时创建）
    LOG_FILE="$CACHE_DIR/.load.log"

    if [ -d "$CACHE_GIT" ]; then
      # 更新现有仓库
      info "Updating existing cache..."
      {
        cd "$CACHE_DIR"
        if git fetch origin main --depth=1 && git reset --hard origin/main; then
          log "Updated cache successfully"
        else
          error "Failed to update cache"
        fi
        cd - > /dev/null
      } 2>&1 | tee -a "$LOG_FILE"
    else
      # 首次克隆：完全重建缓存目录
      info "Cloning claude-common (first time)..."

      # 清理任何残留的目录内容
      [ -d "$CACHE_DIR" ] && rm -rf "$CACHE_DIR"

      # 克隆仓库（直接到新目录）
      if git clone --depth=1 "$REMOTE_REPO" "$CACHE_DIR" > /tmp/clone.log 2>&1; then
        log "Cloned claude-common successfully"
        cat /tmp/clone.log >> "$CACHE_DIR/.load.log"
        rm /tmp/clone.log
      else
        error "Failed to clone claude-common"
        # 不创建 .sync 文件，下次重试
        exit 1
      fi
    fi

    # 同步成功：更新时间戳
    echo "$(date +%s)" > "$SYNC_FILE"
    echo "Synced at $(date)" >> "$CACHE_DIR/.load.log" 2>/dev/null
  fi
else
  info "Using cached rules and skills"
fi

# 初始化目录变量（claude-common 已重构为根目录）
GUIDELINES_DIR="$CACHE_DIR/guidelines"
SKILLS_DIR="$CACHE_DIR/skills"

# 加载和显示规范与 skills
echo ""
echo "📚 Loading guidelines and skills..."

if [ -d "$GUIDELINES_DIR" ]; then
  GUIDE_COUNT=$(find "$GUIDELINES_DIR" -maxdepth 1 -name "*.md" | wc -l)
  log "Found $GUIDE_COUNT remote guidelines"
  find "$GUIDELINES_DIR" -maxdepth 1 -name "*.md" -type f | sort | while read f; do
    info "$(basename "$f")"
  done
else
  warn "Guidelines not found (sync may have failed)"
fi

if [ -d "$SKILLS_DIR" ]; then
  SKILL_COUNT=$(find "$SKILLS_DIR" -maxdepth 1 -type d -not -name "." -not -name ".." | wc -l)
  log "Found $SKILL_COUNT remote skills"
  find "$SKILLS_DIR" -maxdepth 1 -type d -not -name "." -not -name ".." | sort | while read d; do
    info "$(basename "$d")"
  done
else
  warn "Skills not found (sync may have failed)"
fi

# 生成加载配置（收集所有规则和 skills 的路径）
echo ""
echo "⚙️  Generating configuration..."

REMOTE_LOAD=".claude/.remote-load.json"

# 构建 JSON 配置
python3 << 'PYTHON_EOF'
import json
import os
from pathlib import Path

guidelines = []
skills = []

# 收集远程规范（claude-common 已重构为根目录）
remote_guidelines = Path("./.claude/.remote-cache/guidelines")
if remote_guidelines.exists():
    guidelines.extend(str(f.relative_to(".")) for f in sorted(remote_guidelines.glob("*.md")))

# 收集远程 Skills（claude-common 已重构为根目录）
remote_skills = Path("./.claude/.remote-cache/skills")
if remote_skills.exists():
    skills.extend(str(d.relative_to(".")) for d in sorted(remote_skills.iterdir())
                  if d.is_dir() and (d / "SKILL.md").exists())

# 生成配置
config = {
    "comment": "Auto-generated: paths to all guidelines and skills",
    "guidelines": guidelines,
    "skills": skills
}

with open("./.claude/.remote-load.json", "w") as f:
    json.dump(config, f, indent=2, ensure_ascii=False)
    f.write("\n")

print(f"✓ Generated {len(guidelines)} guidelines and {len(skills)} skills")
PYTHON_EOF

if [ $? -eq 0 ]; then
  log "Generated load configuration"
else
  error "Failed to generate configuration"
fi

# 确保 settings.json 中有 skills 配置
if ! grep -q '"skills"' ".claude/settings.json" 2>/dev/null; then
  log "Adding skills configuration to settings.json"
  # 使用 Python 更新 settings.json
  python3 << 'PYTHON_EOF'
import json
from pathlib import Path

settings_file = Path("./.claude/settings.json")
if settings_file.exists():
    with open(settings_file) as f:
        config = json.load(f)

    if "skills" not in config:
        config["skills"] = [
            ".claude/skills",
            ".claude/.remote-cache/skills"
        ]

        with open(settings_file, "w") as f:
            json.dump(config, f, indent=2, ensure_ascii=False)
            f.write("\n")
PYTHON_EOF
fi

# 完成
echo ""
log "Initialization complete!"
echo ""
echo "📖 Configuration:"
info "Remote rules: .claude/.remote-cache/guidelines/"
info "Remote skills: .claude/.remote-cache/skills/"
info "Load config: .claude/.remote-load.json"
echo ""

# 运行验证脚本，确保所有规范和 Skills 都已加载
if [ -f ".claude/hooks/verify-sync.sh" ]; then
  echo "📊 Status:"
  bash .claude/hooks/verify-sync.sh 2>&1 | tail -15
fi

echo ""
echo "🔄 Commands:"
echo "  bash .claude/hooks/auto-load.sh          # Manual sync"
echo "  rm .claude/.remote-cache/.sync           # Force resync"
echo "  bash .claude/hooks/verify-sync.sh        # Check status"
