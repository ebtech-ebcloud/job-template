# 将 S3 中存储的数据同步到集群存储

## 创建 S3 配置文件

1. 准备对应 `S3` 服务的 `Access Key` 和 `Secret Key`, 对应替换 `.s3cfg` 文件中的 `{ACCESS_KEY}`、`${SECRET_KEY}` 字段
2. 执行以下命令生成 `S3` 配置文件 `secret.yaml`

```bash
kubectl create secret generic s3-cfg --from-file=.s3cfg --dry-run=client -o yaml  > secret.yaml
```

3. 执行 `kubectl apply -f secret.yaml` 命令，将 `S3` 配置文件存储到集群

## 创建 PVC

执行 `kubectl apply -f pvc.yaml` 命令, 在集群中创建 PVC

## 运行数据同步 Job

执行 `export IMAGE_NAME=${IMAGE_NAME:-"10.5.1.249/bob/s3cmd:stable"} && envsubst '$IMAGE_NAME' < job.yaml | kubectl replace --force -f -` 命令, 在集群中启动数据同步任务

可以在 `job.yaml` 的 `args` 字段中添加 `--include` 或 `--exclude` 选项来实现文件过滤效果。更详细的使用参数说明，请参考 [s3cmd](https://s3tools.org/usage)
