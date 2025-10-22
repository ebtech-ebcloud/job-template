#!/bin/bash
#准备ComfyUI环境，主要是需要 5个模型文件:2个clip文件，1 个vae文件, 1个unet文件, 1个lora文件
cp /public/huggingface-models/openai/clip-vit-large-patch14/model.safetensors /data/ComfyUI/models/clip/clip-vit-large-patch14.safetensors
cp /public/huggingface-models/comfyanonymous/flux_text_encoders/t5xxl_fp8_e4m3fn.safetensors /data/ComfyUI/models/clip/
cp /public/huggingface-models/black-forest-labs/FLUX.1-dev/vae/diffusion_pytorch_model.safetensors  /data/ComfyUI/models/vae/
export HF_ENDPOINT=https://hf-mirror.com
huggingface-cli download city96/FLUX.1-dev-gguf --include flux1-dev-Q4_0.gguf --local-dir tmp
mv tmp/flux1-dev-Q4_0.gguf /data/ComfyUI/models/unet/
modelscope download --model FluxLora/XLabs-AI-flux-RealismLora --local_dir XLabs-AI-flux-RealismLora
cp XLabs-AI-flux-RealismLora/lora.safetensors /data/ComfyUI/models/loras/flux_realism_lora.safetensors
