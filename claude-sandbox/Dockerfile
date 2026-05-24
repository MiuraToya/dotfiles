# syntax=docker/dockerfile:1

# 汎用の開発ベースとして Debian(bookworm)+ Node LTS を採用。
# Claude Code 本体はネイティブバイナリで Node 非依存だが、
# JS/TS など Node 系リポで便利なので同梱している。
# 他言語(Python / Go など)が要るリポでは、末尾の「拡張ポイント」に追記する。
FROM node:22-bookworm

ARG TZ=Asia/Tokyo
ENV TZ="${TZ}"
ENV DEBIAN_FRONTEND=noninteractive

# エージェントが汎用的によく使うツール + ファイアウォール(任意機能)の依存。
RUN apt-get update && apt-get install -y --no-install-recommends \
      ca-certificates curl gnupg \
      git git-lfs openssh-client \
      less procps sudo \
      jq ripgrep fzf \
      vim nano \
      iptables ipset dnsutils \
    && rm -rf /var/lib/apt/lists/*

# node イメージには非 root の `node` ユーザ(uid 1000)が同梱されている。
# バイパスモード(--dangerously-skip-permissions)は root では起動を拒否するため、
# この非 root ユーザで動かす(= 第一の防御線)。

# 永続化する Claude 設定ディレクトリと作業ディレクトリを用意。
RUN mkdir -p /home/node/.claude /workspace \
    && chown -R node:node /home/node /workspace

# node ユーザには「ファイアウォール初期化スクリプトを root で実行する」権限だけ与える。
# (それ以外の root 権限は与えない)
COPY init-firewall.sh /usr/local/bin/init-firewall.sh
RUN chmod 0755 /usr/local/bin/init-firewall.sh \
    && echo 'node ALL=(root) NOPASSWD: /usr/local/bin/init-firewall.sh' \
       > /etc/sudoers.d/claude-firewall \
    && chmod 0440 /etc/sudoers.d/claude-firewall

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod 0755 /usr/local/bin/entrypoint.sh

# ---- 拡張ポイント: プロジェクト固有のツールが要るならここに追記 ----
# 例) Python:
#   RUN apt-get update && apt-get install -y --no-install-recommends python3 python3-pip \
#       && rm -rf /var/lib/apt/lists/*
# 例) Go / Rust なども同様に。
# -------------------------------------------------------------------

USER node

# Claude Code は公式ネイティブインストーラで導入する。
# (npm 版は環境によりネイティブバイナリの optional 依存を取りこぼし起動できないため)
# node ユーザの ~/.local/bin/claude に入る。
RUN curl -fsSL https://claude.ai/install.sh | bash
ENV PATH="/home/node/.local/bin:${PATH}"

WORKDIR /workspace

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
# このサンドボックスの存在理由そのもの = 既定でバイパスモード起動。
CMD ["claude", "--dangerously-skip-permissions"]
