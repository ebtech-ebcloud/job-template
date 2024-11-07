# 通过 Llama-Factory 进行 LoRA PEFT

## 准备数据集

执行 `make dataset`, 生成示例数据集。其中 `dataset-info` 中包含所有数据集的使用信息，`dataset` 中包含具体的数据集内容。本示例中使用 `ConfigMap` 来存储数据集相关信息，也可以使用 `PVC` 或者其他方式存储数据集内容。

## 准备模型

用户可以从 Huggingface 或者 ModelScope 下载模型，也可以使用自己训练模型。本示例中使用集群共享存储中已经准备好的模型，也可以使用 `PVC` 或者其他方式存储数据集内容。

## Optional: 准备实验指标记录工具以及相关依赖

### [Tensorboard](https://github.com/tensorflow/tensorboard)

#### 使用

本示例中可以通过指定 `--report_to=tensorboard` 参数来使用 `Tensorboard` 记录实验指标，并通过 `--logging_dir` 来指定实验指标将要写入的目录。
您可能需要使用 ```pip install tensorboard``` 来安装 `tensorboard` 模块。

#### 部署

使用 `tensorboard --logdir /app/output/logs` 命令启动一个本地的测试 `Tensorboard` 实例，将 `/app/output/logs` 下的实验指标进行可视化展示。您也可以使用容器化方式进行生产级别的部署，并利用实验指标的**共享存储**来对多个实验指标进行对比。

### [Weights & Biases](https://github.com/wandb/wandb)

#### 使用

本示例中可以通过指定 `--report_to=wandb` 参数来使用 `wandb` 记录实验指标。

获取 `wandb` API Key，然后注入 `wandb` 相关环境变量。以下是一些必要的环境变量配置，全部的可配置环境变量可以参考 [wandb](https://github.com/wandb/client/blob/master/wandb/env.py)。

``` 
# 设定 wandb 服务地址
export WANDB_BASE_URL=https://api.wandb.ai

# 设定 wandb api key
export WANDB_API_KEY=your_api_key_here

# 设定 wandb 中的项目名，您的日志会被记录到对应的项目下
export WANDB_PROJECT=my-awesome-project
```

您可能需要使用 ```pip install wandb``` 来安装 `wandb` 模块。

#### 部署

使用 `wandb server start` 命令启动一个本地的测试 wandb 实例。您也可以使用[容器化等方式](https://docs.wandb.ai/guides/hosting/self-managed/basic-setup/)进行生产级别的部署。

## 准备训练代码

执行 `make script`, 向集群提交示例训练代码。具体的训练代码可以参考 `training-script.sh`。

## 提交单机训练任务

### 单卡训练任务

执行 `make submit-single-node`, 向集群提交单机单卡示例训练任务。

### 单机多卡训练任务

执行 `GPUS_PER_NODE=2 make submit-single-node`, 向集群提交单机两卡示例训练任务。

## 提交多机多卡训练任务

执行 `GPUS_PER_NODE=2 NNODES=2 make submit-multi-node`, 向集群提交两机两卡示例训练任务。
