#!/bin/bash
#假定数据盘的挂载点为/data/,把ComfyUI拷贝到/data,避免模型文件太大撑爆系统盘
source /miniconda/bin/activate comfyui
cp -r /root/ComfyUI /data/
#准备ComfyUI需要的模型，主要是需要 5个模型文件:2个clip文件，1 个vae文件, 1个unet文件, 1个lora文件
#其中有两个文件在拷贝后需要改名
#cp /public/huggingface-models/openai/clip-vit-large-patch14/model.safetensors /public/shared-resources/cache/ComfyUI/models/clip/clip-vit-large-patch14.safetensors
#cp /public/huggingface-models/comfyanonymous/flux_text_encoders/t5xxl_fp8_e4m3fn.safetensors /public/shared-resources/cache/ComfyUI/models/clip/
#cp /public/huggingface-models/black-forest-labs/FLUX.1-dev/vae/diffusion_pytorch_model.safetensors  /public/shared-resources/cache/ComfyUI/models/vae/
#cp /public/huggingface-models/city96/FLUX.1-dev-gguf/flux1-dev-Q4_0.gguf /public/shared-resources/cache/ComfyUI/models/unet/
#cp /public/huggingface-models/XLabs-AI/flux-RealismLora/lora.safetensors /public/shared-resources/cache/ComfyUI/models/loras/flux_realism_lora.safetensors
cp -r /public/shared-resources/cache/ComfyUI/* /root/ComfyUI/
#如果需要自己下载模型，可以采用如下方式
#modelscope download --model FluxLora/XLabs-AI-flux-RealismLora --local_dir XLabs-AI-flux-RealismLora
#cp XLabs-AI-flux-RealismLora/lora.safetensors /data/ComfyUI/models/loras/flux_realism_lora.safetensors
