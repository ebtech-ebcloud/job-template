#! /bin/bash


export NNODES=${NNODES:-2}
export GPUS_PER_NODE=${GPUS_PER_NODE:-1}
export GPU_SPEC=${GPU_SPEC:-A800_NVLINK_80GB}

envsubst '$NNODES $GPUS_PER_NODE $GPU_SPEC' < nccl-tests-mpijob.tpl.yaml | kubectl replace --force -f -