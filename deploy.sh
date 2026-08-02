#!/usr/bin/env bash
set -euo pipefail

echo "🚀 开始构建..."
npx vite build

echo "📁 清理并复制 docs 目录..."
rm -rf docs
cp -r dist docs
cp dist/index.html docs/404.html

echo "🧹 清理视频目录..."
rm -rf docs/videos

echo "📦 提交并推送..."
git add docs/

# 仅当有变更时才提交，避免空提交报错
if git diff --cached --quiet; then
  echo "✅ 没有变更，跳过提交。"
  exit 0
fi

git commit -m "deploy: $(date +%Y-%m-%d)"
git push

echo ""
echo "🎉 部署完成！等 1-2 分钟访问 https://jovinjing.github.io/"
