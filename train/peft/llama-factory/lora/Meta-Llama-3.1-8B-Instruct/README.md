## 在 A800 上通过 Llama-Factory 对 Llama-3.1-8B-Instruct 模型进行 LoRA 微调并验证效果

资源需求：1xA800。

### 前置依赖

需要创建一个存储卷，存储微调后的 LoRA Adapter。

```bash
kubectl apply -f pvc.yaml
```

### 进行微调

可以按需调整具体的资源配置、名称、环境变量、启动参数等。

```bash
kubectl apply -f training-job.yaml
```

多节点 LoRA DDP 训练任务可以使用以下命令提交：

```bash
kubectl apply -f training-job-ddp.yaml
```

### 验证 LoRA 微调结果

通过 `kubectl get job self-cognition-peft-job` 查看 LoRA 任务的状态。如果任务状态为完成 `Complete`，可以使用 `kubectl apply -f inference-job.yaml` 提交推理任务，随后通过 `kubectl logs job/inference` 查看推理结果。
