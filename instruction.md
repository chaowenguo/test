Overview
A distributed PyTorch training job using torch.distributed with mp.spawn hangs indefinitely (deadlocks) when executing under a 2-process setup.

Involved Files and Functions
File: train_job.py

Functions: train_worker and run_training

Expected vs. Actual Behavior
Expected Behavior: The multi-process training script executes successfully across all active ranks, synchronizes properly, and exits cleanly with a return code of 0.

Actual Behavior: The script hangs indefinitely because certain ranks enter conditional branches that skip collective communication operations (such as torch.distributed.all_reduce), while other ranks wait for them at the communication barrier.

Constraints
The task must run successfully within a constrained 2-CPU multi-process environment (world_size = 2).

The solution must prevent process desynchronization and communication deadlocks under asymmetric workload or conditional data distributions.
