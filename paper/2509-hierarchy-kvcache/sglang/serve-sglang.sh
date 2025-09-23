#! /bin/bash

# =========================================================
# 控制是否启用 Mooncake 的开关
# 设置为 "true" 启用，设置为 "false" 关闭
ENABLE_MS=${ENABLE_MS:-true}
# =========================================================
ENABLE_PREFIX_CACHE=${ENABLE_PREFIX_CACHE:-true}

SGLANG_PORT=${PORT:-3000}

# 模型路径和服务名称
MODEL_PATH=${MODEL_PATH:-"/data/models/Qwen/Qwen3-14B"}
SERVED_MODEL_NAME=${MODEL_NAME:-"Qwen/Qwen3-14B"}

LOG_FILE=${LOG_FILE}

# 基础 SGLang 服务命令
CMD="python -m sglang.launch_server"

# 添加基础参数
CMD+=" --model-path ${MODEL_PATH}"
CMD+=" --served-model-name ${SERVED_MODEL_NAME}"
CMD+=" --port ${SGLANG_PORT}"
CMD+=" --host 0.0.0.0"

if [[ "${ENABLE_PREFIX_CACHE}" != "true" ]]; then
    CMD+=" --disable-radix-cache"
fi

# 根据 ENABLE_LMCACHE 变量来添加 LMCache 相关的参数
if [[ "${ENABLE_MS}" == "true" ]]; then
    echo "Mooncake is enabled. Adding --enable-hierarchical-cache and --hicache-storage-backend."
    export MOONCAKE_TE_META_DATA_SERVER="http://localhost:8080/metadata" 
    export MOONCAKE_MASTER="localhost:50051"
    export MOONCAKE_PROTOCOL=${MOONCAKE_PROTOCOL:-"tcp"}
    export MOONCAKE_DEVICE=${MOONCAKE_DEVICE:-""}
    export MC_MS_AUTO_DISC=${MC_MS_AUTO_DISC:-0}
    
    export MOONCAKE_GLOBAL_SEGMENT_SIZE=53687091200
    # 添加 KV 传输配置
    CMD+=" --enable-hierarchical-cache"
    CMD+=" --hicache-storage-backend mooncake"

else
    echo "Mooncake is disabled."
fi

# 最后的命令执行和日志记录
echo "Executing command: ${CMD}"
[[ -n "$LOG_FILE" ]] && eval "${CMD} 2>&1 | tee -a ${LOG_FILE}" || eval "${CMD} 2>&1"
