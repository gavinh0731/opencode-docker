#!/bin/bash
set -e

# 取得使用者輸入的專案路徑，如果沒輸入，預設為當前目錄 (."")
PROJECT_PATH="${1:-.}"

# 將相對路徑轉換為絕對路徑
ABS_PROJECT_PATH=$(cd "$PROJECT_PATH" && pwd)

# Host 使用者資訊
USER_ID=$(id -u)
GROUP_ID=$(id -g)
USER_NAME=$(id -un)
USER_HOME=$HOME


echo "🚀 正在啟動 OpenCode Container..."
echo "📂 Project: $ABS_PROJECT_PATH"
echo "👤 User: $USER_NAME ($USER_ID:$GROUP_ID)"


docker run --rm -it \
    -e LOCAL_UID=${USER_ID} \
    -e LOCAL_GID=${GROUP_ID} \
    -e LOCAL_USER=${USER_NAME} \
    -v "$HOME/opencode-docker/container-data:/home/${USER_NAME}" \
    -v "$ABS_PROJECT_PATH:/workspace" \
    -w /workspace \
    opencode-ai:latest \
    opencode