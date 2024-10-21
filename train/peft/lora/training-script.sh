#!/bin/bash

export NCCL_IB_DISABLE=1

NNODES=${NNODES:-${PET_NNODES}}
NODE_RANK=${NODE_RANK:-${PET_NODE_RANK}}

DISTRIBUTED_ARGS="--nproc_per_node $GPUS_PER_NODE \
	--nnodes $NNODES \
	--node_rank $NODE_RANK \
	--master_addr $MASTER_ADDR \
	--master_port $MASTER_PORT"

TRAIN_ARGS="--dataset_dir $DATASET_DIR \
	--do_train True \
	--finetuning_type lora \
	--stage sft \
	--lora_target all \
	--model_name_or_path /data/models/$MODEL_NAME \
	--output_dir /app/output/$POD_NAME \
	--dataset identity \
	--overwrite_output_dir True \
	--template llama3 \
	--num_train_epochs $EPOCHS \
	--per_device_train_batch_size $TRAIN_BATCH_SIZE_PER_DEVICE"

torchrun $DISTRIBUTED_ARGS /app/src/train.py $TRAIN_ARGS