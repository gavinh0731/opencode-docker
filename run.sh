#!/bin/bash

# 1. 取得使用者輸入的專案路徑，如果沒輸入，預設為當前目錄 (."")
PROJECT_PATH="${1:-.}"

# 2. 將相對路徑轉換為絕對路徑
ABS_PROJECT_PATH=$(cd "$PROJECT_PATH" && pwd)

echo "🚀 正在將專案掛載至 OpenCode 容器..."
echo "📂 本地專案路徑: $ABS_PROJECT_PATH"

# 3. 執行 Docker 容器
docker run --rm -it \
  -v "$HOME/opencode-docker/container-data:/home/ubuntu/.local" \
  -v "$HOME/opencode-docker/container-data/config:/home/ubuntu/.config/opencode" \
  -v "$ABS_PROJECT_PATH:/workspace" \
  -w /workspace \
  -e PATH="/home/ubuntu/.opencode/bin:${PATH}" \
  opencode-ai:latest \
  opencode
