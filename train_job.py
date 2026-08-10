import os
import torch
import torch.distributed as dist
import torch.multiprocessing as mp

def train_worker(rank, world_size, data_tensor):
    os.environ['MASTER_ADDR'] = 'localhost'
    os.environ['MASTER_PORT'] = '12355'
    dist.init_process_group("gloo", rank=rank, world_size=world_size)

    # 模拟 Bug：根据数据大小/内容，只有 rank 0 或偶数 rank 参与计算并调用 all_reduce
    # 奇数 rank 直接跳过，导致进程不同步而挂起（Deadlock）
    local_tensor = data_tensor[rank]
    
    if local_tensor.sum() > 0:
        # 只有满足条件的 rank 才会进入 all_reduce
        dist.all_reduce(local_tensor, op=dist.ReduceOp.SUM)
    else:
        # Bug 所在：没有做全局同步或填充，直接跳过通信，导致死锁
        pass

    dist.destroy_process_group()

def run_training(data_tensor):
    world_size = 2
    mp.spawn(train_worker, args=(world_size, data_tensor), nprocs=world_size, join=True)

if __name__ == "__main__":
    # 构造一个使 Rank 1 满足 sum <= 0，Rank 0 满足 sum > 0 的张量
    # 这会触发条件分支不一致，导致死锁
    data = torch.tensor([[1.0, 2.0], [-1.0, -1.0]])
    run_training(data)
