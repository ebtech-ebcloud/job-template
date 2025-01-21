#! /bin/bash


export NNODES=${NNODES:-2}
export GPUS_PER_NODE=${GPUS_PER_NODE:-1}
export GPU_SPEC=${GPU_SPEC:-A800_NVLINK_80GB}
export IMAGE_NAME=${IMAGE_NAME:-"10.5.1.249/bob-base-image/nccl-tests:12.2.2-cudnn8-devel-ubuntu20.04-nccl2.21.5-1-2ff05b2"}

envsubst '$NNODES $GPUS_PER_NODE $GPU_SPEC' < nccl-tests-mpijob.tpl.yaml | kubectl replace --force -f -