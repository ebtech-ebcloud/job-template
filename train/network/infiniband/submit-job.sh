#! /bin/bash


export NNODES=${NNODES:-2}
export WORKER_NODES=$((NNODES - 1))
export GPUS_PER_NODE=${GPUS_PER_NODE:-1}
export IMAGE_NAME=${IMAGE_NAME:-10.5.1.249/bob-base-image/ibperf:24.07.0-0.44-cuda12.0.1-cudnn8-devel-ubuntu20.04-02}

envsubst '$NNODES $WORKER_NODES $GPUS_PER_NODE $IMAGE_NAME' < ib-perftest-pytorchjob.tpl.yaml | kubectl replace --force -f -