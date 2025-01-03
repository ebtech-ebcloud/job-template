
## vLLM 推理服务部署模版

### 1. 部署 vLLM 推理服务

```bash
# 部署 vLLM 推理的 Deployment
kubectl apply -f inference.tpl.yaml
# 注册推理服务的 Service，分配公网 IP
kubectl apply -f service.yaml
```

### 2. 查看 vLLM 推理服务

```bash
# 本地测试
kubectl exec -it <pod-name> -- bash

curl http://mistral-7b.default.svc.cluster.local/v1/completions \
  -H "Content-Type: application/json" \
  -d '{
        "model": "/public/huggingface-models/mistralai/Mistral-7B-Instruct-v0.3",
        "prompt": "San Francisco is a",
        "max_tokens": 7,
        "temperature": 0
      }'
```


```bash
# 公网 IP 测试

# 查看公网 IP
kubectl get svc mistral-7b

curl http://<public-ip>/v1/completions \
  -H "Content-Type: application/json" \
  -d '{
        "model": "/public/huggingface-models/mistralai/Mistral-7B-Instruct-v0.3",
        "prompt": "San Francisco is a",
        "max_tokens": 7,
        "temperature": 0
      }'
```