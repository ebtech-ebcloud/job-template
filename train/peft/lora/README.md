# 通过 Llama-Factory 进行 LoRA PEFT

## 准备数据集

执行 `make dataset`, 生成示例数据集。其中 `dataset-info` 中包含所有数据集的使用信息，`dataset` 中包含具体的数据集内容。本示例中使用 `ConfigMap` 来存储数据集相关信息，也可以使用 `PVC` 或者其他方式存储数据集内容。

## 准备模型

用户可以从 Huggingface 或者 ModelScope 下载模型，也可以使用自己训练模型。本示例中使用集群共享存储中已经准备好的模型，也可以使用 `PVC` 或者其他方式存储数据集内容。

## 准备训练代码

执行 `make script`, 向集群提交示例训练代码。具体的训练代码可以参考 `training-script.sh`。

## 提交单机训练任务

### 单卡训练任务

执行 `make submit-single-node`, 向集群提交单机单卡示例训练任务。

### 单机多卡训练任务

执行 `GPUS_PER_NODE=2 make submit-single-node`, 向集群提交单机两卡示例训练任务。

## 提交多机多卡训练任务

执行 `GPUS_PER_NODE=2 NNODES=2 make submit-multi-node`, 向集群提交两机两卡示例训练任务。
