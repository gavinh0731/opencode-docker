## 步驟 1 — 專案結構

建立一個資料夾來設置：

```
opencode-docker/
├── Dockerfile.base   # Dockerfile 用來安裝 ubuntu
├── Dockerfile        # Dockerfile 用來安裝 OpenCode AI
├── build.sh          # 腳本用來建立 Docker 映像檔
├── run.sh            # 腳本用來安全地運行 OpenCode AI
├── container-data/   # OpenCode AI 運行時和組態的可寫入資料夾
└── projects/         # AI 專案/程式碼的可寫入資料夾
```

---

### 步驟 2 — Dockerfile

```yaml file:Dockerfile
# OpenCode AI 的 Dockerfile
FROM ubuntu:latest

ENV DEBIAN_FRONTEND=noninteractive

# 安裝依賴
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    git \
    openssh-client \
    sudo \
 && rm -rf /var/lib/apt/lists/*

# 建立非 root 使用者（如果不存在）
RUN id -u ubuntu &>/dev/null || useradd -m -s /bin/bash ubuntu \
 && echo "ubuntu ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/ubuntu \
 && chmod 0440 /etc/sudoers.d/ubuntu

USER ubuntu
WORKDIR /home/ubuntu

# 準備 SSH 組態和 git 的 known_hosts
RUN mkdir -p /home/ubuntu/.ssh \
 && touch /home/ubuntu/.ssh/known_hosts \
 && ssh-keyscan -T 5 github.com 2>/dev/null >> /home/ubuntu/.ssh/known_hosts || true

# 安裝 OpenCode AI
RUN curl -fsSL https://opencode.ai/install | bash

# 將 OpenCode AI 二進位檔加入到 PATH
ENV PATH="/home/ubuntu/.opencode/bin:${PATH}"
```

---

### 步驟 3 — 建立腳本(build.sh)

```bash
#!/bin/bash
set -e

# 建立 OpenCode AI Docker 映像檔
docker build -t opencode-ai:latest .
```

讓它可執行：

```bash
$ chmod 700 build.sh
```

---

### 步驟 4 — 跑步手冊 (run.sh)

```bash
#!/bin/bash

docker run --rm -it \
  # 可寫入的運行時/組態資料夾
  -v "$HOME/opencode-docker/container-data:/home/ubuntu/.local" \
  -v "$HOME/opencode-docker/container-data/config:/home/ubuntu/.config/opencode" \
  # 可寫入的專案工作區
  -v "$HOME/opencode-docker/projects:/workspace" \
  -w /workspace \
  # 確保 OpenCode AI 二進位檔在 PATH 中
  -e PATH="/home/ubuntu/.opencode/bin:${PATH}" \
  opencode-ai:latest \
  opencode
```

讓它可執行：

```bash
$ chmod 700 run.sh
```

---

### 步驟 5 — 設定主機目錄

```bash
mkdir -p ~/opencode-docker/container-data/config
mkdir -p ~/opencode-docker/projects

# 給容器擁有可寫入資料夾的權限
sudo chown -R 1000:1000 ~/opencode-docker/container-data ~/opencode-docker/projects
```

> 這些資料夾是 OpenCode AI 可以安全地儲存運行時檔案和專案程式碼的地方。

---

### 步驟 6 — 建立 Docker Image

```
./build.sh
```

- 這會在非 root 容器中安裝 OpenCode AI。    
- 所有憑證和運行時檔案都保留在映像檔之外。    

---

### 步驟 7 — 運行 OpenCode AI

```bash
$ ./run.sh
```

- 容器使用 `/workspace` 來存放你的專案程式碼。    
- 腳本 (`build.sh` 和 `run.sh`) 對 Docker 來說是唯讀的。    
- OpenCode AI 可以在 `projects/` 建立/編輯檔案，而不會修改你的主機腳本。   

---

### 步驟 8 — 提示

- 將所有敏感的主機憑證保留在映像檔之外。    
- 重新建立映像檔以更新 OpenCode AI： `./build.sh`    
- 在 `projects/` 資料夾內新增新的專案；容器在這裡有寫入權限。    
- 如果你想要額外的安全性，請對腳本使用唯讀掛載 (`:ro`)。    

---

### ✅ 資料夾摘要

| 資料夾                   | 用途               |
| --------------------- | ---------------- |
| `build.sh` ， `run.sh` | 僅限主機，不可變的腳本      |
| `container-data/`     | 可寫入的容器運行時/組態檔案   |
| `專案/`                 | AI 產生的程式碼的可寫入工作區 |


---
### 如何套用到任何目錄？

修改完成後，未來不論你想編輯哪裡的專案，都有以下兩種極其便利的使用方式：

#### 方式 A：直接切換到該專案目錄下執行（最常用）

1. 開啟終端機，切換到你**想編輯的專案目錄**：
```bash
$ cd /path/to/your/any-project
```

2. 直接呼叫 `run.sh` 腳本（不帶參數，它會自動抓取你當前所在的目錄）：
```bash
$ ~/opencode-docker/run.sh
```

#### 方式 B：在任何地方直接傳入專案的絕對或相對路徑

你也可以留在 `opencode-docker` 目錄下，直接把路徑當作參數傳給它：

```
cd ~/opencode-docker
./run.sh /home/username/Desktop/my-web-app
```

### 💡 額外提醒：修正檔案權限問題

由於這個 Dockerfile 內使用的是 `ubuntu` 使用者（UID 1000），當它在你電腦的其他專案目錄建立新檔案時，可能會因為主機權限問題導致你本地無法編輯。

如果你切換到別的專案目錄，記得先確保該目錄的擁有權對容器是友善的。若遇到容器無法讀寫，可以在**該專案目錄**下執行一次：

Bash

```
sudo chown -R 1000:1000 .
```

（這可以確保你本地的使用者與 Docker 內部的 `ubuntu` 使用者都能自由存取並修改專案裡的檔案。）
