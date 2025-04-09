
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

```bash
kubectl apply -f owebui.tpl.yaml
```

这里，我们为该服务申请了一个公网 IP，下边的输出可以看到 owebui-1 的 `EXTERNAL-IP`：
```bash
$ kubectl get svc
NAME                 TYPE           CLUSTER-IP      EXTERNAL-IP      PORT(S)        AGE
kubernetes           ClusterIP      10.233.24.103   <none>           443/TCP        2d1h
owebui-1             LoadBalancer   10.233.20.201   61.135.204.100   80:33936/TCP   141m
qwq-32b-1            ClusterIP      10.233.60.216   <none>           80/TCP         171m
searxng-1            ClusterIP      10.233.21.169   <none>           80/TCP         55m
sglang-leader        ClusterIP      10.233.8.221    <none>           40000/TCP      21h
```

我们只需要本地浏览器打开即可访问：
```bash
# 对于上边的例子，即为： http://61.135.204.100
http://<OPEN-WEBUI-EXTERNAL-IP>
```

*注意*：公网 IP 为收费资源，使用完毕后请及时回收，以免产生预期外的计费。
```bash
# 回收公网 IP，停止计费
kubectl delete service owebui-1
```


## SearXNG 部署

我们通过 SearXNG 为 OpenWebUI 中的模型提供联网搜索能力。
我们已经预先在 OpenWebUI 的配置中开启了该功能，当前 SearXNG 服务部署成功后，即可在 OpenWebUI 中使用。

```bash
kubectl apply -f searxng.tpl.yaml
```