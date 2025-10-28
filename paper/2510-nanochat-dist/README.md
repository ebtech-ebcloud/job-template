# 引言

想要在英博云平台上启动一次大模型分布式训练实验，或快速验证不同的模型架构？本文将以 nanochat 为例，为您介绍在英博云平台上进行模型训练的实践方式，帮助您高效开展 LLM 实验与架构探索，加速模型从原型到验证的全过程。
nanochat 是特斯拉前 AI 总监、OpenAI 创始成员 Andrej Karpathy 近期发布的开源工作。该项目用最少依赖的单一代码库覆盖了从数据准备、分词器训练、模型预训练/微调到模型推理的完整流程。其中 nanochat 的模型预训练阶段可以使用基于 torch 的 DDP 方式进行并行。
本文我们将使用英博云进行 nanochat 的单机训练与多机的分布式训练。我们将从使用单台开发机训练，拓展到使用多台开发机进行训练。随后会为您介绍一种基于 kubeflow 的分布式训练任务提交方式，它可以让我们更简单地将训练拓展到百卡、千卡的规模。

# 创建共享存储卷

为了给模型的训练准备数据，并保存模型训练过程产生的数据，我们创建了一个 128 GB 大小的共享存储卷，并在后续步骤中都配置使用该共享存储卷。
[./images/new_storage.png]
[./images/storage_cfg.png]

# 开发机内直接进行模型训练

开发机即弹性容器实例（Ebtech Container Instance，简称 ECI），支持您挂载 1/2/4/8 个 GPU 或纯 CPU，用于在线调试和模型开发。拥有相比虚拟机实例性能损失少，效率高等优点。

## 运行单机训练任务

### 资源准备

首先，前往英博云的控制台，创建一台 8 卡 A800 开发机。

1. 在开发机创建页面，选择 8 卡 A800 服务器。
2. 选择镜像时，选定“外部镜像”，并填写镜像地址：`registry-cn-huabei1-internal.ebcloud.com/job-template/nanochat:c75fe54`
3. 镜像仓库密码处，选择“无密码”即可。
[./images/cs.png]
4. 挂载已创建的共享存储

开发机启动完毕后，点击开发机实例的右侧按钮 "JupyterLab" 即可打开 Jupyter 页面。我们可以在 JupyterLab 的 Terminal 中执行以下命令快速完成数据准备。我们将创建两个目录分别对开发机单机训练、多机训练时使用和产生的数据进行存放。

``` bash
export NANOCHAT_BASE_DIR=/workdir/cs-standalone
mkdir -p ${NANOCHAT_BASE_DIR}
cp -r /public/shared-resources/cache/nanochat-cache/nanochat/. ${NANOCHAT_BASE_DIR}
export NANOCHAT_BASE_DIR=/workdir/cs-dist
mkdir -p ${NANOCHAT_BASE_DIR}
cp -r /public/shared-resources/cache/nanochat-cache/nanochat/. ${NANOCHAT_BASE_DIR}
```

### 运行任务

我们继续在 JupyterLab 的 Terminal 中执行以下命令运行任务，您也可以在 Terminal 中启动一个 Tmux Session 并执行以下命令。

``` bash
cd /root/nanochat
source .venv/bin/activate
source "$HOME/.cargo/env"
export NANOCHAT_BASE_DIR=/workdir/cs-standalone

torchrun --standalone \
    --nproc_per_node=8 \
    -m scripts.base_train \
    -- --depth=20 \
    --device_batch_size=32 \
    --total_batch_size=1048576
```

随后我们可以在 JupyterLab Terminal 中观察到对应的训练日志。

``` bash
step 00029/10700 (0.27%) | loss: 6.296391 | lrm: 1.00 | dt: 2225.85ms | tok/sec: 235,544 | mfu: 20.79 | total time: 0.71m
step 00030/10700 (0.28%) | loss: 6.265557 | lrm: 1.00 | dt: 2223.26ms | tok/sec: 235,819 | mfu: 20.81 | total time: 0.74m
step 00031/10700 (0.29%) | loss: 6.241041 | lrm: 1.00 | dt: 2220.22ms | tok/sec: 236,142 | mfu: 20.84 | total time: 0.78m
```

## 运行多机训练任务

### 资源准备

我们按照单机训练任务中的操作，再次创建一台 8 卡 A800 开发机，并挂载我们之前创建的共享存储。
[./images/cpu_cs.png]

### 运行任务

我们选择将新创建的 8 卡 A800 开发机 nano22 与上一步中使用的 8 卡 A800 开发机 nano12 一起使用来进行多机训练。相较于单机训练，多机训练时训练节点之间需要使用 rank 为 0 的 master 节点的固定端口作为桥梁进行通信，还需要给每个训练节点分配 rank 等信息。
分别点击两台开发机实例的右侧按钮 "JupyterLab" 打开 Jupyter 页面：

1. 在 `nano12` 开发机的 JupyterLab 的 Terminal 中执行以下命令
   1. 获取 `nano12` 开发机在集群内的地址
      1. `hostname -i`，从命令输出中可以得到 `nano12` 的集群内地址为 `10.233.75.95`。我们将选用 `nano12` 作为两机训练的 master 节点，并使用 `23456` 作为通信的端口
   2. 指定 rank 以及 master 连接信息，启动训练任务的 master 节点

``` bash
cd /root/nanochat
source .venv/bin/activate
source "$HOME/.cargo/env"
export NANOCHAT_BASE_DIR=/workdir/cs-dist

torchrun --nnodes=2 \
    --node_rank=0 \
    --master_addr=10.233.75.95 \
    --nproc_per_node=8 \
    --master_port=23456 \
    -m scripts.base_train \
    -- --depth=20 \
    --device_batch_size=32 \
    --total_batch_size=1048576
```

2. 在 `nano22` 开发机的 JupyterLab 的 Terminal 中执行以下命令启动训练任务，手动指定 `nano22` 的 rank 为 1，并使用 `nano12` 节点的集群内地址 `10.233.75.95` 和 `23456` 端口进行通信

``` bash
cd /root/nanochat
source .venv/bin/activate
source "$HOME/.cargo/env"
export NANOCHAT_BASE_DIR=/workdir/cs-dist

torchrun --nnodes=2 \
    --node_rank=1 \
    --master_addr=10.233.75.95 \
    --nproc_per_node=8 \
    --master_port=23456 \
    -m scripts.base_train \
    -- --depth=20 \
    --device_batch_size=32 \
    --total_batch_size=1048576
```

随后我们可以在作为 master 节点的 nano12 的 JupyterLab Terminal 中观察到对应的训练日志。

``` text
step 00029/10700 (0.27%) | loss: 6.269156 | lrm: 1.00 | dt: 1137.04ms | tok/sec: 922,199 | mfu: 20.35 | total time: 0.43m
step 00030/10700 (0.28%) | loss: 6.239355 | lrm: 1.00 | dt: 1143.00ms | tok/sec: 917,392 | mfu: 20.24 | total time: 0.45m
step 00031/10700 (0.29%) | loss: 6.214127 | lrm: 1.00 | dt: 1139.73ms | tok/sec: 920,019 | mfu: 20.30 | total time: 0.46m
```

可以看到我们将单机 8 卡的训练 scale 到双机 16 卡之后，每个 Step 的耗时从 2.2s 左右降低到了 1.1s，符合线性的提升。
随着训练任务节点规模的提高，依然通过手动的方式逐个对训练任务进行拉起显然是低效且容易出错的。我们还提供了基于配置的训练任务提交方式，训练任务提交后会按照配置被自动拉起、运行。

## 通过开发机提交训练任务

### 资源准备

我们可以在英博云上申请一台 CPU 开发机，方便获取和使用英博云提供的各种内置资源，在挂载已创建的共享存储后，还可以方便地查看训练日志、模型 checkpoints 等数据。
[./images/nanochat-dist-create-cpu-dev.png]
开发机启动完毕后，点击开发机实例的右侧按钮 "JupyterLab" 即可打开 Jupyter 页面。我们将在 JupyterLab 的 Terminal 中完成以下的所有步骤，实现提交和运行单机与多机的训练任务。

### 配置 kubectl 连接集群

我们可以参考英博云的帮助文档 [https://docs.ebtech.com/docs/cluster/attach.html](https://docs.ebtech.com/docs/cluster/attach.html) 来配置 kubectl 并连接集群。

### 安装基础组件

执行以下命令安装 kubeflow 的 training-operator 组件。training-operator 可以让用户快速进行基于 TensorFlow、PyTorch、MXNet、XGBoost 等框架的分布式训练。

``` bash
kubectl apply -f /public/shared-resources/k8s-resources/training-operator/v1.8.0/manifests.yaml
```

### 数据准备

执行以下命令完成数据准备。我们将创建两个目录分别对 kubeflow 单机训练、多机训练时使用和产生的数据进行存放。

``` bash
mkdir -p /workdir/kf-standalone
cp -r /public/shared-resources/cache/nanochat-cache/nanochat/. /workdir/kf-standalone
mkdir -p /workdir/kf-dist
cp -r /public/shared-resources/cache/nanochat-cache/nanochat/. /workdir/kf-dist
```

接下来，我们仍将会基于 `registry-cn-huabei1-internal.ebcloud.com/job-template/nanochat:c75fe54` 镜像来进行单机 8 卡 A800 与双机 16 卡 A800 训练任务的配置与提交。

### 提交单机训练任务

执行以下命令来提交单机训练任务。YAML 文件中主要对单机的训练节点进行了配置，执行的 `torchrun` 命令与在开发机内进行单机训练时的相似，只是 `--nproc_per_node` 选项的值使用了 kubeflow 为我们提供的环境变量 `PET_NPROC_PER_NODE`。值得注意的是，YAML 文件中还配置使用了已创建的共享存储卷并将训练日志写入到对应目录下。

``` bash
kubectl apply -f /public/shared-resources/k8s-resources/training-operator/v1.8.0/examples/nanochat-standalone.yaml
```

  以下列出了一些常见命令来查看本次实验单机训练任务 master 节点的相关状态与日志。

``` bash
# 查看 master 节点的状态
kubectl get po nano-standalone-master-0
# 查看 master 节点的详细状态
kubectl describe po nano-standalone-master-0
# 查看 master 节点的日志
kubectl logs -f nano-standalone-master-0
# 查找不同 rank 训练节点的日志文件
ls /workdir/kf-standalone | grep log
```

### 提交多机训练任务

执行以下命令来提交多机训练任务。相较于单机训练任务，YAML 配置文件中新增了 Worker 部分的配置，并且 Master 与 Worker 部分中新增了 NCCL 相关的配置， `torchrun` 命令中使用了 kubeflow 动态为我们计算的 `PET_` 开头的环境变量，使得我们不需要再对 rank、master 等信息进行手动配置。此外通过配置 Worker 的 `replicas` 字段，可以快速地 scale 训练规模，得益于 kubeflow 为我们自动配置了每一个训练节点，我们无需再手动逐个进行配置。

```bash
kubectl apply -f /public/shared-resources/k8s-resources/training-operator/v1.8.0/examples/nanochat-dist.yaml
```

同样我们可以使用以下命令来查看本次实验多机训练任务 master 节点的相关状态与日志。

``` bash
# 查看 master 节点的状态
kubectl get po nano-kf-master-0
# 查看 master 节点的详细状态
kubectl describe po nano-kf-master-0
# 查看 master 节点的日志
kubectl logs -f nano-kf-master-0
# 查找不同 rank 训练节点的日志文件
ls /workdir/kf-dist | grep log
```

### 调整训练任务

我们可以将上述步骤使用到的单机训练配置 YAML 文件与多机训练配置 YAML 文件拷贝到 CPU 开发机的 `/workdir` 目录，然后修改文件做训练资源配置、训练参数等的调整，然后使用类似的 `kubectl apply -f {file_name}` 方式来提交训练任务。以 nanochat 为例，我们可以参考 base_train.py 中的参数对模型层数、优化器等训练细节进行调整，并对应修改 `command` 字段中的内容。
更多关于训练配置的说明可以参考我们的 Github Repo [https://github.com/ebtech-ebcloud/job-template/tree/main/paper/2510-nanochat-dist](https://github.com/ebtech-ebcloud/job-template/tree/main/paper/2510-nanochat-dist)。

本文介绍了在英博云平台上使用 A800 资源进行单机与多机模型训练的两种方式。在模型训练规模较小时，用户可以直接使用 GPU 开发机快速进行验证和实验，而在需要进行大规模训练时，通过提交训练任务的方式可以无缝快速地扩大规模。此外英博云平台还提供 H800 等类型的其他资源，用户可以自由选用进行模型开发工作。
