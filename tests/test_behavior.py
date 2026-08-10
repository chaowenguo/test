import subprocess
import pytest
import time

def test_distributed_training_no_deadlock():
    # 设置超时时间（例如 5 秒）。如果有死锁，进程会挂起直到超时失败。
    start_time = time.time()
    try:
        result = subprocess.run(
            ["python3", "/workspace/train_job.py"],
            capture_output=True,
            text=True,
            timeout=5
        )
        assert result.returncode == 0, f"Training failed with stderr: {result.stderr}"
    except subprocess.TimeoutExpired:
        pytest.fail("Distributed training hung due to a deadlock (timeout after 5 seconds).")
