import json
import os
import sys

def parse_results():
    config_path = "/tests/config.json"
    log_path = "/logs/verifier/pytest_output.log"
    reward_path = "/logs/verifier/reward.txt"
    
    os.makedirs(os.path.dirname(reward_path), exist_ok=True)

    if not os.path.exists(config_path) or not os.path.exists(log_path):
        with open(reward_path, "w") as f:
            f.write("0")
        return

    with open(config_path, "r") as f:
        config = json.load(f)

    fail_to_pass = config.get("fail_to_pass", [])
    pass_to_pass = config.get("pass_to_pass", [])

    with open(log_path, "r") as f:
        log_content = f.read()

    # 简单检查 pytest 运行日志中目标测试是否全部通过 (PASSED)
    all_passed = True
    for test_name in fail_to_pass:
        # 类似 "test_distributed_training_no_deadlock PASSED"
        if f"{test_name} PASSED" not in log_content:
            all_passed = False
            break

    for test_name in pass_to_pass:
        if f"{test_name} PASSED" not in log_content:
            all_passed = False
            break

    reward = "1" if all_passed else "0"
    with open(reward_path, "w") as f:
        f.write(reward)

if __name__ == "__main__":
    parse_results()
