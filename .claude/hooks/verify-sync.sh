#!/bin/bash
# .claude/hooks/verify-sync.sh
# 验证远程规范同步状态和加载情况

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() { echo -e "${GREEN}✓${NC} $1"; }
warn() { echo -e "${YELLOW}⚠${NC} $1"; }
error() { echo -e "${RED}✗${NC} $1"; }
info() { echo -e "${BLUE}ℹ${NC} $1"; }

# 从 claude.env 读取配置
CONFIG_ENV=".claude/config/claude.env"
if [ -f "$CONFIG_ENV" ]; then
  set -a
  source "$CONFIG_ENV"
  set +a
fi

# 使用从 env 读取的值，或使用默认值
CACHE_DIR="${COMMON_CACHE_DIR:-.claude/.remote-cache}"

SYNC_FILE="$CACHE_DIR/.sync"
LOG_FILE="$CACHE_DIR/.load.log"

echo "📊 Claude Code Sync Status Report"
echo "=================================="
echo ""

# 1. 检查缓存状态
echo "🔍 Cache Status:"
if [ -d "$CACHE_DIR/.git" ]; then
  log "Cache directory exists"

  if [ -f "$SYNC_FILE" ]; then
    LAST_SYNC=$(stat -f%m "$SYNC_FILE" 2>/dev/null || stat -c%Y "$SYNC_FILE" 2>/dev/null)
    CURRENT_TIME=$(date +%s)
    ELAPSED=$((CURRENT_TIME - LAST_SYNC))
    HOURS_AGO=$(($ELAPSED / 3600))
    DAYS_AGO=$(($ELAPSED / 86400))

    if [ $DAYS_AGO -eq 0 ]; then
      log "Last synced: ${HOURS_AGO} hours ago"
    else
      warn "Last synced: ${DAYS_AGO} days ago"
    fi
  else
    error "No sync timestamp found"
  fi

  # 检查 git 状态
  cd "$CACHE_DIR"
  if git rev-parse --git-dir > /dev/null 2>&1; then
    COMMIT=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")
    BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
    log "Git: $BRANCH @ $COMMIT"
  fi
  cd - > /dev/null
else
  error "Cache directory not found"
  echo "  Run: bash .claude/hooks/auto-load.sh"
  exit 1
fi

echo ""

# 2. 检查规范文件
echo "📚 Guidelines:"
GUIDELINES_DIR="$CACHE_DIR/guidelines"
if [ -d "$GUIDELINES_DIR" ]; then
  GUIDE_COUNT=$(find "$GUIDELINES_DIR" -maxdepth 1 -name "*.md" | wc -l)
  log "Remote: $GUIDE_COUNT guidelines"
  find "$GUIDELINES_DIR" -maxdepth 1 -name "*.md" -type f | sort | while read f; do
    echo "    $(basename "$f")"
  done
else
  error "Remote guidelines not found"
fi

echo ""

# 3. 检查 Skills
echo "🔧 Skills:"
SKILLS_DIR="$CACHE_DIR/skills"
if [ -d "$SKILLS_DIR" ]; then
  SKILL_COUNT=$(find "$SKILLS_DIR" -maxdepth 1 -type d -not -name "." -not -name ".." | wc -l)
  log "Remote: $SKILL_COUNT skills"
  find "$SKILLS_DIR" -maxdepth 1 -type d -not -name "." -not -name ".." | sort | while read d; do
    SKILL_NAME=$(basename "$d")
    SKILL_DESC=$(grep -h "^# " "$d/SKILL.md" 2>/dev/null | head -1 | sed 's/^# //' || echo "(no description)")
    echo "    $SKILL_NAME - $SKILL_DESC"
  done
else
  error "Remote skills not found"
fi

LOCAL_SKILLS="./.claude/skills"
if [ -d "$LOCAL_SKILLS" ]; then
  LOCAL_SKILL_COUNT=$(find "$LOCAL_SKILLS" -maxdepth 1 -type d -not -name "." -not -name ".." | wc -l)
  if [ $LOCAL_SKILL_COUNT -gt 0 ]; then
    log "Local: $LOCAL_SKILL_COUNT skills"
    find "$LOCAL_SKILLS" -maxdepth 1 -type d -not -name "." -not -name ".." | sort | while read d; do
      echo "    $(basename "$d")"
    done
  fi
fi

echo ""

# 4. 检查加载配置
echo "⚙️  Configuration:"
if [ -f "./.claude/.remote-load.json" ]; then
  log "Load config exists (.claude/.remote-load.json)"
  TOTAL_ITEMS=$(grep -c '".*"' ./.claude/.remote-load.json || echo "?")
  info "$TOTAL_ITEMS items configured"
else
  warn "Load config not found (will be generated on next sync)"
fi

echo ""

# 5. 显示日志
if [ -f "$LOG_FILE" ]; then
  echo "📋 Latest sync log entries:"
  tail -5 "$LOG_FILE" | sed 's/^/  /'
fi

echo ""
echo "✅ Status report complete"
echo ""
echo "💡 Useful commands:"
echo "  bash .claude/hooks/auto-load.sh       # Manual sync"
echo "  rm .claude/.remote-cache/.sync        # Force resync next time"
echo "  cat .claude/.remote-cache/.load.log   # View full sync log"
