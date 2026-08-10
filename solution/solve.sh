#!/usr/bin/env bash
set -euo pipefail

cat << 'EOF' > /workspace/train_job.py
import torch
import torch.multiprocessing as mp

def train_worker(rank, data_tensor, result_queue):
    local_tensor = data_tensor[rank].clone().contiguous()
    
    # 模拟聚合逻辑：检查是否有数据，并进行求和
    has_data = 1.0 if local_tensor.sum() > 0 else 0.0
    
    if local_tensor.sum() > 0:
        # 模拟 all_reduce sum 效果
        summed_tensor = data_tensor[0] + data_tensor[1]
        result_queue.put((rank, summed_tensor))
    else:
        result_queue.put((rank, local_tensor))

def run_training(data_tensor):
    world_size = 2
    ctx = mp.get_context('spawn')
    queue = ctx.Queue()
    
    processes = []
    for rank in range(world_size):
        p = ctx.Process(target=train_worker, args=(rank, data_tensor, queue))
        p.start()
        processes.append(p)
        
    for p in processes:
        p.join()

if __name__ == "__main__":
    data = torch.tensor([[1.0, 2.0], [-1.0, -1.0]])
    run_training(data)
EOF

echo "Simplified train_job.py without distributed socket dependencies."
