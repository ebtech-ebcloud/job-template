
## 在 A800 上部署 DeepSeek R1 的 INT8 版本

资源需求：16xA800，建议使用 2 个 8 卡 A800 实例。

### 前置依赖
我们借助 LeaderWorkerSet 来完成。

```bash
# k8s LWS setup
# https://github.com/kubernetes-sigs/lws/blob/main/docs/examples/sglang/README.md
VERSION=v0.6.0
wget https://github.com/kubernetes-sigs/lws/releases/download/$VERSION/manifests.yaml

# small patch to the lws manifests
sed -i '' '/memory: 1Gi/a\
          limits:\
            cpu: 2\
            memory: 2Gi
' manifests.yaml

sed -i '' 's/registry.k8s.io/registry-cn-huabei1-internal.ebcloud.com\/registry.k8s.io/g' manifests.yaml
 
# now install to k8s server
kubectl apply --server-side -f manifests.yaml
```


### 使用公共模型存储进行部署
可以按需调整具体的资源配置、名称、环境变量、启动参数等。

```bash
kubectl apply -f lws_with_public_storage.yaml
```


### 使用私有模型进行部署

** 前置依赖 **
需要在 yaml 文件中配置自己的共享存储名称，在云平台页面创建共享存储时，指定的名称。
例如需要配置的共享存储名为 mydata ，可通过如下命令替换，或手动查找将文件中的 "data02" 替换 "mydata"：

```bash
# 说明，lws_with_private_storage.yaml 中示例的共享存储名为 data02
sed -i '' 's/data02/mydata/g' lws_with_private_storage.yaml
```

修改完成后，就可以进行服务部署了：
```bash
kubectl apply -f lws_with_private_storage.yaml
```


