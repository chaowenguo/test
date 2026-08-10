#!/usr/bin/env bash
set -uo pipefail

# 创建日志目录
mkdir -p /logs/verifier

# 1. 运行测试脚本
if [ -f "/tests/run_script.sh" ]; then
  bash /tests/run_script.sh || true
else
  echo "Error: run_script.sh not found!" >&2
fi

# 2. 调用解析器生成 reward.txt
if [ -f "/tests/parser.py" ]; then
  python3 /tests/parser.py
else
  # 如果没有 parser.py，兜底写入 0
  echo "0" > /logs/verifier/reward.txt
fi

# 3. 确保奖励文件存在且内容有效
if [ ! -f "/logs/verifier/reward.txt" ]; then
  echo "0" > /logs/verifier/reward.txt
fi
