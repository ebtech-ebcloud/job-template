
# 多层级 KV-Cache 的使用

基于英博云（ebcloud.com）平台可快速复现本文的结论。
> 关于英博云：
> 英博云提供了企业级 GPU 容器云服务，基于 kubernetes 提供了灵活、易用的 GPU 容器服务。

在开始之前，请确保已创建集群，并安装了 kubectl，且将 kubeconfig 配置到了本地默认路径：`~/.kube/config`

具体操作方式可参考英博云平台的帮助文档：
- 账号注册：https://docs.ebtech.com/docs/quickstart/prepare.html
- 创建集群：https://docs.ebtech.com/docs/cluster/create.html
- 连接集群：https://docs.ebtech.com/docs/cluster/attach.html
- kubectl 常用命令：https://docs.ebtech.com/docs/cluster/command.html

本文将基于我们预装好的镜像启动实验环境，除了下边的启动方式，也可直接使用此镜像作为“外部镜像”启动开发机进行使用：
- 镜像名称：registry-cn-huabei1-internal.ebcloud.com/job-template/sglang-with-lmcache:v0.5.3rc1-cu126
- 镜像名称：registry-cn-huabei1-internal.ebcloud.com/job-template/vllm-openai-with-lmcache:v0.10.1.1

## vLLM + LMCache

### 创建一个 vLLM + LMCache 的实验环境

该环境中我们启动了一个 vLLM 服务并配置其使用 LMCache 作为 KV-Cache 扩展，并使用一个 Python 脚本去调用 vLLM 服务，统计 `TTFT` 与 `E2E latency`。
我们可以通过调整 `ENABLE_LMCACHE`、`ENABLE_PREFIX_CACHE` 环境变量来控制是否启用 LMCache 和 Prefix Cache，调整 `MODEL_NAME`、`MODEL_PATH` 环境变量来控制使用的模型，调整 `LMCACHE_CONFIG_FILE` 环境变量来控制使用的 LMCache 配置。


```bash
kubectl apply -f vllm/experiment.yaml
```

### 查看 vLLM 日志

```bash
kubectl logs -f -n default deploy/vllm-lmcache-a800 -c vllm
```

### 进行实验

```bash
kubectl exec -ti -n default deploy/vllm-lmcache-a800 -c devbox -- python3 do_request.py
```

### 清除实验环境

```bash
kubectl delete -f vllm/experiment.yaml
```

## SGLang HiCache

### 创建一个 SGLang HiCache 的实验环境

该环境中我们启动了一组 Mooncake 的 MetaServer、MasterServer 以及 StoreService 服务作为 SGLang HiCache 的存储后端，启动了一个 SGLang 服务与其进行通信，并使用一个 Python 脚本去调用 SGLang 服务，统计 `TTFT` 与 `E2E latency`。
我们可以通过调整 `ENABLE_MS` 环境变量来控制是否启用 MooncakeStore，调整 `MODEL_NAME`、`MODEL_PATH` 环境变量来控制使用的模型。

```bash
kubectl apply -f sglang/experiment.yaml
```

### 查看 Mooncake 服务日志

```bash
kubectl logs -f -n default deploy/sglang-hicache-a800 -c mc-metaserver
kubectl logs -f -n default deploy/sglang-hicache-a800 -c mc-master
kubectl logs -f -n default deploy/sglang-hicache-a800 -c mc-store
```

### 查看 SGLang 日志

```bash
kubectl logs -f -n default deploy/sglang-hicache-a800 -c sglang
```

### 进行实验

```bash
kubectl exec -ti -n default deploy/sglang-hicache-a800 -c devbox -- python3 do_request.py
```

### 清除实验环境

```bash
kubectl delete -f sglang/experiment.yaml
```