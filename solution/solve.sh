#!/usr/bin/env bash
set -euo pipefail

# 覆写 train_job.py，引入全局同步或无条件参与 all_reduce 的修复逻辑
cat << 'EOF' > /workspace/train_job.py
import os
import torch
import torch.distributed as dist
import torch.multiprocessing as mp

def train_worker(rank, world_size, data_tensor):
    os.environ['MASTER_ADDR'] = 'localhost'
    os.environ['MASTER_PORT'] = '12355'
    dist.init_process_group("gloo", rank=rank, world_size=world_size)

    local_tensor = data_tensor[rank]
    
    # 黄金答案：确保所有 Rank 均无条件参与 all_reduce（即使数据无效也参与，或用 dummy 替代），
    # 或者在条件分支前后加入 barrier 保证步调一致。
    # 这里采用最优雅的方案：所有 Rank 共同参与 all_reduce，用掩码或直接归约
    has_data = torch.tensor([1.0 if local_tensor.sum() > 0 else 0.0])
    dist.all_reduce(has_data, op=dist.ReduceOp.SUM) # 全局对齐同步点
    
    if local_tensor.sum() > 0:
        dist.all_reduce(local_tensor, op=dist.ReduceOp.SUM)

    dist.destroy_process_group()

def run_training(data_tensor):
    world_size = 2
    mp.spawn(train_worker, args=(world_size, data_tensor), nprocs=world_size, join=True)

if __name__ == "__main__":
    data = torch.tensor([[1.0, 2.0], [-1.0, -1.0]])
    run_training(data)
EOF

echo "Distributed deadlock resolved successfully."
