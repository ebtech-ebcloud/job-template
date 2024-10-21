#!/bin/bash

export NNODES=${NNODES:-2}
export WORKER_NODES=$((NNODES - 1))
export MODEL_NAME=${MODEL_NAME:-Meta-Llama-3.1-8B-Instruct}
export GPUS_PER_NODE=${GPUS_PER_NODE:-2}
export EPOCHS=${EPOCHS:-2}
export TRAIN_BATCH_SIZE_PER_DEVICE=${TRAIN_BATCH_SIZE_PER_DEVICE:-2}

envsubst '$MODEL_NAME $NNODES $WORKER_NODES $GPUS_PER_NODE $EPOCHS $TRAIN_BATCH_SIZE_PER_DEVICE' < lora-example-pytorchjob.tpl.yaml | kubectl replace --force -f -

