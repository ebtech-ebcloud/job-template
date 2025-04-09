
## QWQ-32B 的部署

部署方案：
- SGLang


### 服务部署
```bash
kubectl apply -f inference.tpl.yaml
```
可根据需要选择部署方式，需修改资源申请量和启动参数 `TP`：
- 1卡 A800: `TP=1`
- 2卡 A800: `TP=2`
- 4卡 A800: `TP=4`

### 验证部署
```bash
# 窗口 1 进行 port forward
$ kubectl port-forward service/qwq-32b-1 \
    8180:80 \
    -n default

# 窗口 2 进行接口调用
$ curl http://localhost:8180/v1/models
$ curl http://localhost:8180/v1/completions \
  -H "Content-Type: application/json" \
  -d '{
        "model": "qwq-32b",
        "prompt": "北京是一个",
        "max_tokens": 10,
        "temperature": 0
      }'

```

## OpenWebUI 的部署

