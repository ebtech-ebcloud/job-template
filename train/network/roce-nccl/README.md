

```bash
# 向集群注册启动脚本
make script

# 向集群提交任务，实际执行 bash submit-job.sh
make submit
```

样例输出：
```
# nThread 1 nGpus 1 minBytes 536870912 maxBytes 2147483648 step: 2(factor) warmup iters: 50 iters: 50 agg iters: 1 validation: 1 graph: 0
#
# Using devices
#  Rank  0 Group  0 Pid   1164 on kubeflow-nccl-test-3-master-0 device  0 [0x10] NVIDIA A800-SXM4-80GB
#  Rank  1 Group  0 Pid   1165 on kubeflow-nccl-test-3-master-0 device  1 [0x16] NVIDIA A800-SXM4-80GB
#  Rank  2 Group  0 Pid     77 on kubeflow-nccl-test-3-worker-0 device  0 [0xc1] NVIDIA A800-SXM4-80GB
#  Rank  3 Group  0 Pid     78 on kubeflow-nccl-test-3-worker-0 device  1 [0xc7] NVIDIA A800-SXM4-80GB
#  Rank  4 Group  0 Pid     71 on kubeflow-nccl-test-3-worker-1 device  0 [0x51] NVIDIA A800-SXM4-80GB
#  Rank  5 Group  0 Pid     72 on kubeflow-nccl-test-3-worker-1 device  1 [0x56] NVIDIA A800-SXM4-80GB
#  Rank  6 Group  0 Pid     71 on kubeflow-nccl-test-3-worker-2 device  0 [0x10] NVIDIA A800-SXM4-80GB
#  Rank  7 Group  0 Pid     72 on kubeflow-nccl-test-3-worker-2 device  1 [0x16] NVIDIA A800-SXM4-80GB
#  Rank  8 Group  0 Pid     77 on kubeflow-nccl-test-3-worker-3 device  0 [0x90] NVIDIA A800-SXM4-80GB
#  Rank  9 Group  0 Pid     78 on kubeflow-nccl-test-3-worker-3 device  1 [0x95] NVIDIA A800-SXM4-80GB
#  Rank 10 Group  0 Pid     59 on kubeflow-nccl-test-3-worker-4 device  0 [0xc6] NVIDIA A800-SXM4-80GB
#  Rank 11 Group  0 Pid     60 on kubeflow-nccl-test-3-worker-4 device  1 [0xca] NVIDIA A800-SXM4-80GB
#  Rank 12 Group  0 Pid     71 on kubeflow-nccl-test-3-worker-5 device  0 [0x21] NVIDIA A800-SXM4-80GB
#  Rank 13 Group  0 Pid     72 on kubeflow-nccl-test-3-worker-5 device  1 [0x27] NVIDIA A800-SXM4-80GB
#  Rank 14 Group  0 Pid     77 on kubeflow-nccl-test-3-worker-6 device  0 [0x49] NVIDIA A800-SXM4-80GB
#  Rank 15 Group  0 Pid     78 on kubeflow-nccl-test-3-worker-6 device  1 [0x4d] NVIDIA A800-SXM4-80GB
#  Rank 16 Group  0 Pid     59 on kubeflow-nccl-test-3-worker-7 device  0 [0x21] NVIDIA A800-SXM4-80GB
#  Rank 17 Group  0 Pid     60 on kubeflow-nccl-test-3-worker-7 device  1 [0x27] NVIDIA A800-SXM4-80GB
#  Rank 18 Group  0 Pid     65 on kubeflow-nccl-test-3-worker-8 device  0 [0x90] NVIDIA A800-SXM4-80GB
#  Rank 19 Group  0 Pid     66 on kubeflow-nccl-test-3-worker-8 device  1 [0x95] NVIDIA A800-SXM4-80GB
#  Rank 20 Group  0 Pid     65 on kubeflow-nccl-test-3-worker-9 device  0 [0xc1] NVIDIA A800-SXM4-80GB
#  Rank 21 Group  0 Pid     66 on kubeflow-nccl-test-3-worker-9 device  1 [0xc7] NVIDIA A800-SXM4-80GB
#  Rank 22 Group  0 Pid     65 on kubeflow-nccl-test-3-worker-10 device  0 [0x8a] NVIDIA A800-SXM4-80GB
#  Rank 23 Group  0 Pid     66 on kubeflow-nccl-test-3-worker-10 device  1 [0x8f] NVIDIA A800-SXM4-80GB
#
#                                                              out-of-place                       in-place          
#       size         count      type   redop    root     time   algbw   busbw #wrong     time   algbw   busbw #wrong
#        (B)    (elements)                               (us)  (GB/s)  (GB/s)            (us)  (GB/s)  (GB/s)       
   536870912     134217728     float     sum      -1    24942   21.52   41.26      0    24966   21.50   41.22      0
  1073741824     268435456     float     sum      -1    49507   21.69   41.57      0    49613   21.64   41.48      0
  2147483648     536870912     float     sum      -1    97276   22.08   42.31      0    97204   22.09   42.34      0
# Out of bounds values : 0 OK
# Avg bus bandwidth    : 41.6967 
#
```
