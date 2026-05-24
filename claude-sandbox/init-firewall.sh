#!/bin/bash
# コンテナの外向き通信(egress)を「明示的に許可したホストだけ」に絞り込む。
# 既定 DROP + 許可リストなので、危険コマンドによる情報持ち出し先を制限できる。
# 注意: これは exfiltration を「困難」にするものであって完全には防げない
#       (許可した GitHub / npm 等を経由した持ち出しは理論上あり得る)。
set -euo pipefail
IFS=$'\n\t'

echo "[firewall] initializing egress allowlist..."

# 既存ルールをクリア
iptables -F
iptables -X 2>/dev/null || true
iptables -t nat -F 2>/dev/null || true
iptables -t nat -X 2>/dev/null || true
iptables -t mangle -F 2>/dev/null || true
iptables -t mangle -X 2>/dev/null || true
ipset destroy allowed-domains 2>/dev/null || true

# 先に DNS / loopback / 確立済みコネクションを許可しておく
# (この時点では既定ポリシーがまだ ACCEPT なので名前解決や curl が通る)
iptables -A OUTPUT -p udp --dport 53 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 53 -j ACCEPT
iptables -A INPUT  -p udp --sport 53 -j ACCEPT
iptables -A INPUT  -p tcp --sport 53 -j ACCEPT
iptables -A INPUT  -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT
iptables -A INPUT  -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

ipset create allowed-domains hash:net

add_domain() {
  local domain="$1" ips ip
  ips=$(dig +short A "$domain" 2>/dev/null || true)
  if [ -z "$ips" ]; then
    echo "[firewall] WARN: could not resolve $domain" >&2
    return
  fi
  while read -r ip; do
    [ -z "$ip" ] && continue
    if [[ "$ip" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
      ipset add allowed-domains "$ip" 2>/dev/null || true
    fi
  done <<< "$ips"
}

# GitHub は CIDR レンジを公開しているのでそれを取り込む(git/npm 経由の取得用)
echo "[firewall] adding GitHub ranges..."
gh_ranges=$(curl -s --max-time 10 https://api.github.com/meta || true)
if [ -n "$gh_ranges" ]; then
  echo "$gh_ranges" \
    | jq -r '(.web + .api + .git + .packages)[]?' 2>/dev/null \
    | grep -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/' \
    | while read -r cidr; do ipset add allowed-domains "$cidr" 2>/dev/null || true; done
fi

# Claude / npm に必要なドメインを許可
for d in \
  api.anthropic.com \
  console.anthropic.com \
  statsig.anthropic.com \
  statsig.com \
  sentry.io \
  registry.npmjs.org \
  ; do
  echo "[firewall] allow $d"
  add_domain "$d"
done

# ここから既定 DROP に切り替え
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT DROP

# 許可リスト宛の egress のみ通す
iptables -A OUTPUT -m set --match-set allowed-domains dst -j ACCEPT

echo "[firewall] done. egress restricted to the allowlist."
