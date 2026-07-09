# sudo docker build -f Dockerfile.base -t opencode-base .;

# OpenCode AI 的 Dockerfile
FROM opencode-base

# 安裝 OpenCode (先用 root 安裝到系統)
RUN curl -fsSL https://opencode.ai/install | bash \
    && mv /root/.opencode /opt/opencode \
    && ln -s /opt/opencode/bin/opencode /usr/local/bin/opencode

# EntryPoint
COPY resources/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

RUN chmod +x /usr/local/bin/docker-entrypoint.sh

WORKDIR /workspace

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

CMD ["bash"]