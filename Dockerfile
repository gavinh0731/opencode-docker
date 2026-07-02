# sudo docker build -f Dockerfile.base -t opencode-base .;

# OpenCode AI 的 Dockerfile
FROM opencode-base

# 安裝 OpenCode AI
RUN curl -fsSL https://opencode.ai/install | bash

# 將 OpenCode AI 二進位檔加入到 PATH
ENV PATH="/home/ubuntu/.opencode/bin:${PATH}"
