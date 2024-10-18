#!/bin/bash

export MODEL_NAME=${MODEL_NAME:-Meta-Llama-3.1-8B-Instruct}
export GPUS_PER_NODE=${GPUS_PER_NODE:-1}
export EPOCHS=${EPOCHS:-2}
export TRAIN_BATCH_SIZE_PER_DEVICE=${TRAIN_BATCH_SIZE_PER_DEVICE:-2}

envsubst '$MODEL_NAME $GPUS_PER_NODE $EPOCHS $$TRAIN_BATCH_SIZE_PER_DEVICE' < lora-example-job.tpl.yaml | kubectl replace --force -f -
