# 一张消费级显卡能支持的大模型应用

在开始之前，请确保已创建集群，并将 kubeconfig 配置到了本地默认路径：
```
~/.kube/config
```

## ComfyUI应用
bash /root/prep\_comfyui.sh
然后在本地界面用ssh建立本机8080端口和开发机8080端口的端口转发，即可在本地用浏览器访问8080端口。

## OpenWebUI应用
bash /root/start\_owu.sh
然后在本地界面用ssh建立本机8080端口和开发机8080端口的端口转发，即可在本地用浏览器访问8080端口。
