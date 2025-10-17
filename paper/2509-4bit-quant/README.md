
# 4位量化模型的推理性能评测

在开始之前，请确保已创建集群，并将 kubeconfig 配置到了本地默认路径：
```
~/.kube/config
```


## 4bit LLM Inference Benchmark

### 创建实验环境
首先，请务必将 yaml 文件中的密码设置部分，`YOUR@PASS#WORD` 替换为自己的密码
如需 SSH 通过公网 ip:port 登陆，可将 yaml 中，底部的 ssh service 的 spec.type 设置为 LoadBalancer，这样会同步注册一个公网 IP 并分配端口，供 ssh 登陆使用。
```
# 启动A800测试节点
kubectl apply -f quant-a800-2cards.yaml

# 登陆服务器
kubectl exec -it svc/quant-a800-ssh -- bash
```

### 启动模型推理服务
启动服务，可以根据需要自行选择 vllm 或者 sglang：
```
# vllm
conda activate vllm
MODEL_PATH=/public/huggingface-models/Qwen/Qwen3-32B
vllm serve $MODEL_PATH --async-scheduling --tensor-parallel-size 2
```

### 性能测试
压力测试我们可以使用 sglang bench\_serving：
```
conda activate vllm
cp /public/huggingface-datasets/anon8231489123/ShareGPT_Vicuna_unfiltered/ShareGPT_V3_unfiltered_cleaned_split.json /tmp
export HF_ENDPOINT=https://hf-mirror.com
# 每次运行时调整 --seed 来避免命中 cache
# 调整压力：--num-prompts 为总请求数量，--max-concurrency 为最大并发数，--request-rate 为每秒发送的请求数
MODEL_PATH=/public/huggingface-models/Qwen/Qwen3-32B
python3 -m sglang.bench_serving --backend vllm \
    --model $MODEL_PATH \
    --dataset-name random \
    --random-range-ratio 1 \
    --num-prompt 128 \
    --request-rate 1 \
    --random-input 2048 \
    --random-output 2048 \
    --max-concurrency 32 \
    --tokenizer $MODEL_PATH --seed $(date +'%H%M%S')
```

### 精度测试
精度测试用lm\_eval工具进行, 数据集已经放在/root/gsm8k.
数据集的处理参考如下链接:  
https://github.com/EleutherAI/lm-evaluation-harness/blob/main/docs/new_task_guide.md#using-local-datasets  
然后即可运行lm\_eval任务。
```
lm_eval --model vllm --model_args \
    pretrained=/public/huggingface-models/Qwen/Qwen3-32B,tensor_parallel_size=2,dtype=auto,gpu_memory_utilization=0.92 \
    --tasks gsm8k-cot --batch_size auto --gen_kwargs="max_gen_toks=2048" --include_path /root
lm_eval --model vllm --model_args \
    pretrained=/public/huggingface-models/Qwen/Qwen3-32B-AWQ,tensor_parallel_size=1,dtype=auto,gpu_memory_utilization=0.8 \
    --tasks gsm8k-cot --batch_size auto --gen_kwargs="max_gen_toks=2048 --include_path /root
```

### 模型量化
模型量化采用/root/quant\_fp4.py


## Image Generation with FLUX.1-dev
直接激活环境并运行即可，在 4090 上运行 BF16 版本的模型时，需要开启 CPU offload，否则显存不足以容纳完整的模型权重。
```
conda activate nunchaku 
#利用nunchaku的transformer流程运行4位flux.1-dev模型
python /root/flux.1-dev.py
#在上述模型上叠加lora训练的模型
python /root/flux.1-dev-lora.py
```
