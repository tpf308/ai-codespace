#!/usr/bin/env bash
# 在云端 Linux 环境（ModelScope / PAI-DSW / 百度 AI Studio 等）起一条 VS Code 隧道，
# 让本地 VSCode 通过 "Remote - Tunnels" 扩展连进来——无需公网 SSH，能穿防火墙。
#
# 用法：
#   bash tunnel.sh         # 前台运行，按提示用 GitHub 账号授权
#   bash tunnel.sh -d      # 后台常驻，日志写到 ~/tunnel.log（用 cat ~/tunnel.log 看授权链接）
#
# 可选：自定义隧道名（小写字母/数字/连字符，<=20 字符）
#   export TUNNEL_NAME=my-dev
#
# 本地连接：装 "Remote - Tunnels" 扩展 → F1 → Remote Tunnels: Connect to Tunnel → 同一个 GitHub 账号
set -e

NAME="${TUNNEL_NAME:-cloud-dev}"
DIR="$HOME/.local/vscode-cli"
CLI="$DIR/code"

# 1) 下载 VS Code CLI（已存在则跳过）
if [ ! -x "$CLI" ]; then
  echo "下载 VS Code CLI…"
  mkdir -p "$DIR"
  curl -Lk 'https://code.visualstudio.com/sha/download?build=stable&os=cli-alpine-x64' -o /tmp/vscode_cli.tar.gz
  tar -xf /tmp/vscode_cli.tar.gz -C "$DIR"
fi

# 2) 起隧道
if [ "${1:-}" = "-d" ]; then
  nohup "$CLI" tunnel --accept-server-license-terms --name "$NAME" > "$HOME/tunnel.log" 2>&1 &
  echo "✅ 隧道已后台启动（名字：$NAME）。"
  echo "   运行 cat ~/tunnel.log 查看授权链接（首次需 GitHub 授权）。"
else
  echo "前台启动隧道（名字：$NAME），按提示授权后别关这个终端。Ctrl+C 可停。"
  "$CLI" tunnel --accept-server-license-terms --name "$NAME"
fi
