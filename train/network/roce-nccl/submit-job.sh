
#! /bin/bash

export JOB_NAME=${JOB_NAME:-kubeflow-nccl-test-5}
export NNODES=${NNODES:-2}
export WORKER_NODES=$((NNODES - 1))
export GPUS_PER_NODE=${GPUS_PER_NODE:-8}
# default to 10*GPUS_PER_NODE
export CPUS_PER_NODE=${CPUS_PER_NODE:-$((${GPUS_PER_NODE} * 10))}
# default to 100*GPUS_PER_NODE
export MEMORY_PER_NODE=${MEMORY_PER_NODE:-$((${GPUS_PER_NODE} * 100))}Gi
export IMAGE_NAME=${IMAGE_NAME:-registry-cn-beijing2-internal.ebtech.com/job-template/nccl-tests:v2.13.8-nccl2.23.4-ibperf24.07.0-cuda12.0.1-cudnn8-devel-ubuntu20.04-1}
# export IMAGE_NAME=${IMAGE_NAME:-10.5.1.249/bob-base-image/nccl-test:v2.13.8-nccl2.23.4-ibperf24.07.0-cuda12.0.1-cudnn8-devel-ubuntu20.04-1}

envsubst '$JOB_NAME $NNODES $WORKER_NODES $GPUS_PER_NODE $CPUS_PER_NODE $MEMORY_PER_NODE $IMAGE_NAME' < nccl-test-pytorchjob.tpl.yaml | kubectl replace --force -f -