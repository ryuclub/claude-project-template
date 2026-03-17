#!/bin/bash
# init-project.sh - 初始化 Claude Code 项目
#
# 用法示例：
#   bash <(curl -s https://raw.githubusercontent.com/ryuclub/claude-project-template/main/init-project.sh) my-project
#   bash <(wget -qO- https://raw.githubusercontent.com/ryuclub/claude-project-template/main/init-project.sh) my-project
#
# 执行后会自动：
#   1. 创建项目目录
#   2. 获取 claude-project-template 模板（或更新现有的）
#   3. 复制 .claude 配置到项目
#   4. 初始化 claude.env 配置文件
#   5. 提示后续步骤

set -e

# 检查参数
if [ -z "$1" ]; then
  echo "❌ 缺少项目名称"
  echo ""
  echo "用法: bash <(curl -s <url>) <项目名称>"
  echo ""
  echo "示例："
  echo "  bash <(curl -s https://raw.githubusercontent.com/ryuclub/claude-project-template/main/init-project.sh) my-project"
  echo "  bash <(curl -s ...) /tmp/my-project"
  echo "  bash <(curl -s ...) ~/projects/my-project"
  exit 1
fi

PROJECT_PATH="$1"
PROJECT_NAME=$(basename "$PROJECT_PATH")

echo "🚀 初始化 Claude Code 项目: $PROJECT_NAME"
echo ""

# 1. 创建项目目录
echo "📁 创建项目目录: $PROJECT_PATH"
mkdir -p "$PROJECT_PATH"
cd "$PROJECT_PATH"

# 2. 获取模板
echo "📥 获取 claude-project-template..."
git clone https://github.com/ryuclub/claude-project-template.git

# 3. 复制模板内容到项目根目录
echo "📋 复制模板文件..."
cp -r claude-project-template/* .
cp -r claude-project-template/.* . 2>/dev/null || true  # 复制隐藏文件（如.gitignore）

# 4. 删除不再需要的模板文件和git配置
echo "🗑️  清理模板文件..."
rm -rf claude-project-template
rm -rf .git  # 删除复制来的git配置（remote指向模板项目）

# 5. 删除模板README并创建项目README
echo "📝 创建项目README..."
rm -f README.md
cat > README.md << 'EOF'
# 项目名称

项目描述

## 快速开始

## 功能

## 项目结构

## 相关文档

- `.claude/CLAUDE.md` - AI 行为指南和项目规范
- `.claude/README.md` - Claude Code 配置说明（如需要）
EOF

# 6. 初始化配置文件
echo "⚙️  初始化 claude.env..."
cp .claude/config/claude.env.example .claude/config/claude.env

# 7. 提示用户编辑配置
echo ""
echo "✅ 项目初始化完成！"
echo ""
echo "📂 项目结构："
echo "  $PROJECT_PATH/"
echo "  ├── .claude/                      # Claude Code 配置"
echo "  │   ├── CLAUDE.md                # AI 行为指南"
echo "  │   ├── settings.json            # Claude Code 设置"
echo "  │   ├── hooks/                   # 自动化钩子"
echo "  │   ├── guidelines/              # 项目规范"
echo "  │   ├── config/"
echo "  │   │   ├── claude.env           # 🔐 凭证（本地，不提交）"
echo "  │   │   ├── claude.env.example   # 配置模板"
echo "  │   │   └── infrastructure.md    # 基础设施参考"
echo "  │   └── .remote-cache/           # 自动生成的缓存"
echo "  ├── README.md                     # 项目说明"
echo "  ├── init-project.sh              # 初始化脚本"
echo "  └── .gitignore                    # Git 忽略配置"
echo ""
echo "📝 接下来的步骤："
echo ""
echo "  1️⃣  编辑配置文件:"
echo "     vi .claude/config/claude.env"
echo ""
echo "     必填项："
echo "     • ATLASSIAN_USERNAME      (JIRA邮箱)"
echo "     • ATLASSIAN_API_KEY       (JIRA token)"
echo "     • ATLASSIAN_DOMAIN        (JIRA域名)"
echo "     • JIRA_PROJECT            (项目代码，如 MOS)"
echo "     • GITHUB_ORG              (GitHub组织)"
echo "     • GITHUB_REPO             (GitHub仓库)"
echo "     • GIT_REPO_URL            (Git URL)"
echo "     • GIT_BRANCH_BASE         (基础分支，通常 main)"
echo ""
echo "  2️⃣  （可选）初始化 git:"
echo "     git init"
echo "     git remote add origin https://github.com/YOUR_ORG/$PROJECT_NAME.git"
echo "     git add .claude/"
echo "     git commit -m \"初始化 Claude Code 配置\""
echo ""
echo "  3️⃣  启动 Claude Code"
echo "     Claude Code 会自动加载 .claude/config/claude.env"
echo ""
echo "📚 更多信息:"
echo "  • 项目说明: $PROJECT_PATH/README.md"
echo "  • 项目指南: $PROJECT_PATH/.claude/CLAUDE.md"
echo ""
