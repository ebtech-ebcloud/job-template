#!/bin/bash
source /miniconda/bin/activate sglang
nohup python3 -m sglang.launch_server --model  /public/huggingface-models/\
Qwen/Qwen3-8B-FP8/  --tp 1 --trust-remote-code --mem-fraction-static 0.65 >log_sglang.txt 2>&1 &
source /miniconda/bin/activate open-webui
export MINERU_MODEL_SOURCE=modelscope
export MINERU_VIRTUAL_VRAM_SIZE=6
export PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True
nohup mineru-api --host 0.0.0.0 --port 8000 >log_mineru.txt 2>&1 &
cd /root/open-webui/backend
export HF_ENDPOINT=https://hf-mirror.com
nohup sh dev.sh >/root/log_owu.txt 2>&1 &
