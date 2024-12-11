#!/bin/bash

export NCCL_IB_DISABLE=1

NNODES=${NNODES:-${PET_NNODES}}
NODE_RANK=${NODE_RANK:-${PET_NODE_RANK}}
DATASET_TEMPLATE=${DATASET_TEMPLATE:-deepseek}
DEEPSPEED_CONFIG=${DEEPSPEED_CONFIG:-examples/deepspeed/ds_z3_config.json}

DISTRIBUTED_ARGS="--nproc_per_node $GPUS_PER_NODE \
	--nnodes $NNODES \
	--node_rank $NODE_RANK \
	--master_addr $MASTER_ADDR \
	--master_port $MASTER_PORT"

TRAIN_ARGS="--dataset_dir ${DATASET_DIR:-/app/data} \
	--dataset ${DATASET:-wiki_demo} \
	--stage pt \
	--do_train True \
	--finetuning_type full \
	--lora_target all \
	--model_name_or_path /data/models/$MODEL_NAME \
	--output_dir /app/output/$POD_NAME \
	--overwrite_output_dir True \
	--overwrite_cache \
	--cutoff_len 4096 \
	--template $DATASET_TEMPLATE \
	--num_train_epochs $EPOCHS \
	--per_device_train_batch_size $TRAIN_BATCH_SIZE_PER_DEVICE \
	--per_device_eval_batch_size ${EVAL_BATCH_SIZE_PER_DEVICE:-${TRAIN_BATCH_SIZE_PER_DEVICE}} \
	--report_to $REPORT_TO \
	--logging_dir $LOGGING_DIR \
	--preprocessing_num_workers 160 \
	--gradient_accumulation_steps 4 \
	--lr_scheduler_type cosine \
	--logging_steps 1 \
	--warmup_steps 1000 \
	--save_steps 2000 \
	--eval_steps 1000 \
	--evaluation_strategy steps \
	--load_best_model_at_end \
	--learning_rate 5e-5 \
	--val_size 10 \
	--plot_loss \
	--bf16 true \
	--warmup_ratio 0.02 \
	--ddp_timeout 300000000 \
	--save_on_each_node True \
	--flash_attn auto \
	--gradient_checkpointing True \
	--weight_decay 0.01 \
	--max_grad_norm 1.0 \
	--save_total_limit 10 \
	--max_steps 100 \
	--streaming False \
	--deepspeed $DEEPSPEED_CONFIG"

torchrun $DISTRIBUTED_ARGS /app/src/train.py $TRAIN_ARGS