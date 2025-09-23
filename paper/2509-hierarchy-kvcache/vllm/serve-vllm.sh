#! /bin/bash

# =========================================================
# 控制是否启用 LMCache 的开关
# 设置为 "true" 启用，设置为 "false" 关闭
ENABLE_LMCACHE=${ENABLE_LMCACHE:-true}
# =========================================================

ENABLE_PREFIX_CACHE=${ENABLE_PREFIX_CACHE:-true}

VLLM_PORT=${PORT:-8000}

# LMCache 配置文件的路径
LMCACHE_CONFIG_FILE=${LMCACHE_CONFIG_FILE:-"lmcache_config_disk.yaml"}

# 模型路径和服务名称
MODEL_PATH=${MODEL_PATH:-"/data/models/Qwen/Qwen3-14B"}
SERVED_MODEL_NAME=${MODEL_NAME:-"Qwen/Qwen3-14B"}

# LMCache 的 KV 传输配置参数
# 注意：vLLM 要求这个 JSON 字符串是单行的
KV_TRANSFER_CONFIG='{"kv_connector":"LMCacheConnectorV1", "kv_role":"kv_both"}'
LOG_FILE=${LOG_FILE}

# 基础 vLLM 服务命令
CMD="vllm serve"

# 添加基础参数
CMD+=" ${MODEL_PATH}"
CMD+=" --served_model_name ${SERVED_MODEL_NAME}"
CMD+=" --port ${VLLM_PORT}"

if [[ "${ENABLE_PREFIX_CACHE}" != "true" ]]; then
    CMD+=" --no-enable-prefix-caching"
fi

# 根据 ENABLE_LMCACHE 变量来添加 LMCache 相关的参数
if [[ "${ENABLE_LMCACHE}" == "true" ]]; then
    echo "LMCache is enabled. Adding --kv-transfer-config."
    # 启用实验性功能和配置文件
    export LMCACHE_USE_EXPERIMENTAL=True
    export LMCACHE_CONFIG_FILE="${LMCACHE_CONFIG_FILE}"
    # 添加 KV 传输配置
    CMD+=" --kv-transfer-config '${KV_TRANSFER_CONFIG}'"
else
    echo "LMCache is disabled."
fi

# 最后的命令执行和日志记录
echo "Executing command: ${CMD}"
[[ -n "$LOG_FILE" ]] && eval "${CMD} 2>&1 | tee -a ${LOG_FILE}" || eval "${CMD} 2>&1"
