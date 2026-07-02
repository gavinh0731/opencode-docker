#!/bin/bash
set -e

# 建立 OpenCode AI Docker Base 映像檔
sudo docker build -f Dockerfile.base -t opencode-base .;
# 建立 OpenCode AI Docker 映像檔
sudo docker build -f Dockerfile -t opencode-ai:latest . --no-cache;
