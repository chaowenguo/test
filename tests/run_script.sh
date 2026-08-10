#!/usr/bin/env bash
set -uo pipefail

mkdir -p /logs/verifier
cd /workspace

# 运行 pytest 并将结果输出到日志
pytest -v /tests/test_behavior.py > /logs/verifier/pytest_output.log 2>&1 || true
