
# 常见卡型号的单卡负载对比

基于英博云（ebcloud.com）平台可快速复现本文的结论。
> 关于英博云：
> 英博云提供了企业级 GPU 容器云服务，基于 kubernetes 提供了灵活、易用的 GPU 容器服务。

在开始之前，请确保已创建集群，并安装了 kubectl，且将 kubeconfig 配置到了本地默认路径：`~/.kube/config`

具体操作方式可参考英博云平台的帮助文档：
- 账号注册：https://docs.ebtech.com/docs/quickstart/prepare.html
- 创建集群：https://docs.ebtech.com/docs/cluster/create.html
- 连接集群：https://docs.ebtech.com/docs/cluster/attach.html


## LLM Serving with gpt-oss-20b

### 创建实验环境
首先，请务必将 yaml 文件中的密码设置部分，`YOUR@PASS#WORD` 替换为自己的密码
如需 SSH 通过公网 ip:port 登陆，可将 yaml 中，底部的 ssh service 的 spec.type 设置为 LoadBalancer，这样会同步注册一个公网 IP 并分配端口，供 ssh 登陆使用。
```
# 启动 4090 测试节点
kubectl apply -f inference-compare-4090.yaml 

# 登陆服务器
kubectl exec -it svc/inference-compare-4090-ssh -- bash
```

### 启动模型推理服务
启动服务，可以根据需要自行选择 vllm 或者 sglang：
```
# vllm
conda activate vllm
vllm serve /public/huggingface-models/openai/gpt-oss-20b --trust-remote-code --port 8000 --served-model-name openai/gpt-oss-20b --async-scheduling

# sglang，根据卡型号，需在 A800,H800 选择 --cuda-graph-max-bs 256
conda activate sglang
python3 -m sglang.launch_server --model /public/huggingface-models/openai/gpt-oss-20b --trust-remote-code --port 8000 --served-model-name openai/gpt-oss-20b --cuda-graph-max-bs 32 --mem-fraction-static 0.92
```

### 性能测试
使用 curl 进行单请求的功能测试：
```
curl localhost:8000/v1/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "openai/gpt-oss-20b",
    "prompt": "Beijing is a ",
    "stream":true,
    "max_tokens": 3000
  }'
```

压力测试我们可以使用 sglang bench_serving：
```
conda activate sglang

cp /public/huggingface-datasets/anon8231489123/ShareGPT_Vicuna_unfiltered/ShareGPT_V3_unfiltered_cleaned_split.json /tmp

export HF_ENDPOINT=https://hf-mirror.com
# 每次运行时调整 --seed 来避免命中 cache
# 调整压力：--num-prompts 为总请求数量，--max-concurrency 为最大并发数，--request-rate 为每秒发送的请求数
python3 -m sglang.bench_serving --backend vllm --port 8000 --seed 100 \
    --model openai/gpt-oss-20b --dataset-name random \
    --random-output-len 1000 --random-input-len 6000 --random-range-ratio 1 \
    --request-rate 8 --num-prompts 1 --max-concurrency 10
```



## Image Generation with FLUX.1-dev

直接激活环境并运行即可，在 4090 上运行 BF16 版本的模型时，需要开启 CPU offload，否则显存不足以容纳完整的模型权重。
```
conda activate diffuser
# 默认使用原版 bf16 格式的模型，不开启 cpu offload
python /root/run_flux.py
# 4090 使用原版 bf16 格式的模型生成时，需要开启 CPU offload
CPU_OFFLOAD=1 python /root/run_flux.py
```