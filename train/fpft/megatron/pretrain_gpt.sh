#!/bin/bash
set -x

echo "===> submit job for JOBNAME: $JOB_NAME"


WORK_DIR='/workspace'

CHECKPOINT_PATH=/data/ckpt/llama3-8b-tp2-pp4-vp2-1001/
CKPT_DEP_PATH=${WORK_DIR}/ckpt-dep/
VOCAB_FILE=${CKPT_DEP_PATH}gpt2-vocab.json
MERGE_FILE=${CKPT_DEP_PATH}gpt2-merges.txt
TOKENIZER_MODEL=${CHECKPOINT_PATH}tokenizer.model

GPUS_PER_NODE=${GPUS_PER_NODE:-8}
# WORLD_SIZE=$(($GPUS_PER_NODE*$NNODES))

MICRO_BATCH_SIZE=${MICRO_BATCH_SIZE:-1}
GLOBAL_BATCH_SIZE=${GLOBAL_BATCH_SIZE:-16}
TRAIN_ITERS=${TRAIN_ITERS:-4000}

LOG_INTERVAL=${LOG_INTERVAL:-10}
SAVE_INTERVAL=${SAVE_INTERVAL:-1000}
EVAL_INTERVAL=${EVAL_INTERVAL:-300}
EVAL_ITERS=${EVAL_ITERS:-10}

TP=${TP:-1}
PP=${PP:-1}

# ==============
# training args
# ==============

    # --use-distributed-optimizer \
    # --recompute-activations \
    # --attention-softmax-in-fp32 \

    # --recompute-granularity full \
    # --recompute-method uniform \
    # --recompute-num-layers 4 \
    # --distribute-saved-activations \

    # --recompute-activations \
    # --recompute-granularity selective \

    # --recompute-granularity full \
    # --recompute-method uniform \
    # --recompute-num-layers 2 \

GPT_ARGS="
    --group-query-attention \
    --num-query-groups 8 \
    --fp16 \
    --finetune \
    --overlap-grad-reduce \
    --use-flash-attn \
    --tensor-model-parallel-size ${TP} \
    --pipeline-model-parallel-size ${PP} \
    --num-layers ${NUM_LAYERS} \
    --hidden-size ${HIDDEN_SIZE} \
    --ffn-hidden-size ${FFN_HIDDEN_SIZE} \
    --num-attention-heads ${NUM_ATTENTION_HEADS} \
    --seq-length ${SEQ_LENGTH} \
    --max-position-embeddings ${MAX_POSITION_EMBEDDINGS} \
    --tokenizer-type Llama3Tokenizer \
    --tokenizer-model ${TOKENIZER_MODEL} \
    --exit-on-missing-checkpoint \
    --no-load-optim \
    --no-load-rng \
    --untie-embeddings-and-output-weights \
    --normalization RMSNorm \
    --position-embedding-type rope \
    --no-masked-softmax-fusion \
    --micro-batch-size ${MICRO_BATCH_SIZE} \
    --global-batch-size ${GLOBAL_BATCH_SIZE} \
    --lr 0.00015 \
    --train-iters ${TRAIN_ITERS} \
    --lr-decay-iters 320 \
    --lr-decay-style cosine \
    --min-lr 1.0e-5 \
    --weight-decay 1e-2 \
    --lr-warmup-fraction .01 \
    --swiglu \
    --clip-grad 1.0
"

    # --auto-detect-ckpt-format \
    # --use-distributed-optimizer \
    # --distribute-saved-activations \
    # --use-dist-ckpt \
if [ -n "$LAYER_PER_VPP" ]; then
    EXTRA_GPT_ARGS="
        --num-layers-per-virtual-pipeline-stage ${LAYER_PER_VPP}
    "
else
    EXTRA_GPT_ARGS=""
fi

    # --use-checkpoint-args \
    # --pipeline-model-parallel-size 2 \
    # --sequence-parallel \

DATA_ARGS="
    --mock-data \
    --split 949,50,1
"
    # --data-path $DATA_PATH \
    # --mock-data \
    # --vocab-file $VOCAB_FILE \
    # --merge-file $MERGE_FILE \

OUTPUT_ARGS="
    --log-interval ${LOG_INTERVAL} \
    --log-throughput \
    --save-interval ${SAVE_INTERVAL} \
    --eval-interval ${EVAL_INTERVAL} \
    --eval-iters ${EVAL_ITERS}
"

# ======================
#  user custom functions
# ======================

preprocess() {
    echo "---> prepare model ..."
#    rclone copy eb:ckpt/kueue-finetune-model-convert-1002/ $CHECKPOINT_PATH
#    mkdir -p $CHECKPOINT_PATH
    echo "---> prepare data ..."
#    rclone copy eb:model/gpt2-vocab.json $CHECKPOINT_PATH
#    rclone copy eb:model/gpt2-merges.txt $CHECKPOINT_PATH
    echo "---> ckpt dir : "
    ls $CHECKPOINT_PATH
#    sleep 120
}

postprocess() {
    if [ $PET_NODE_RANK -eq 0 ]; then
        echo "---> checkpoint to be saved: "
        ls -lah $CHECKPOINT_PATH
        # REMOTE_DIR="eb:ckpt/$JOB_NAME/"
        # echo "---> saving to remote storage ..."
        # rclone copy $CHECKPOINT_PATH $REMOTE_DIR
        # echo "---> ckpt saved to remote storage : $REMOTE_DIR"
        # rclone lsd $REMOTE_DIR

        # echo "===> save nccl logs to $REMOVE_DIR"
        # rclone copy $DEBUG_LOG_FILE $REMOTE_DIR
        # rclone copy $TOPO_LOG_FILE $REMOTE_DIR
    fi
}

# =========================================================================== #
# ============================= 后续代码无需修改 =============================== #
# =========================================================================== #

# ================
# distributed args
# ================

NNODES=$PET_NNODES
NODE_RANK=$PET_NODE_RANK

DISTRIBUTED_ARGS="
    --nproc_per_node $GPUS_PER_NODE \
    --nnodes $NNODES \
    --node_rank $NODE_RANK \
    --master_addr $MASTER_ADDR \
    --master_port $MASTER_PORT
"


# ===================================
#  CUDA & NCCL environment variables
# ===================================

export CUDA_DEVICE_MAX_CONNECTIONS=1

# export NCCL_SOCKET_IFNAME=eth0
# export NCCL_IB_DISABLE=1
# export NCCL_NET_GDR_LEVEL=0
# export NCCL_DEBUG=TRACE
# export NCCL_DEBUG_SUBSYS=ALL
export NCCL_IB_HCA='mlx5_0,mlx5_1,mlx5_2,mlx5_5,mlx5_6,mlx5_7,mlx5_8,mlx5_11'
export NCCL_DEBUG=${NCCL_DEBUG}
export NCCL_DEBUG_SUBSYS=${NCCL_DEBUG_SUBSYS}
export NCCL_TIMEOUT_MS=60000 # 设置常规 NCCL 操作的超时时间
export NCCL_LAUNCH_TIMEOUT=60000  # 设置 NCCL 拓扑发现和初始化阶段的超时时间
export NCCL_COMM_ID_TIMEOUT=60000  # 设置 NCCL 通信 ID 交换的超时时间
export NCCL_SOCKET_TIMEOUT=60000  # 设置 NCCL 套接字连接的超时时间
# export NCCL_DEBUG_FILE=nccl_debug.log
# export NCCL_TOPO_DUMP_FILE=nccl_topo.xml



# ==================
#  run training job
# ==================

echo "===> pre process ..."
preprocess

echo "===> launch training job ..."
cd $WORK_DIR; torchrun $DISTRIBUTED_ARGS pretrain_gpt.py \
    $EXTRA_GPT_ARGS \
    $GPT_ARGS \
    $DATA_ARGS \
    $OUTPUT_ARGS \
    --distributed-backend nccl \
    --save $CHECKPOINT_PATH \
    --load $CHECKPOINT_PATH

echo "===> post process ..."
postprocess

echo "===> job finished."