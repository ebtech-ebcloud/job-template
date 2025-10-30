#!/bin/bash
#假定数据盘的挂载点为/data/,把ComfyUI拷贝到/data,避免模型文件太大撑爆系统盘
source /miniconda/bin/activate comfyui
cp -r /root/ComfyUI /data/
#准备ComfyUI需要的模型，主要是需要 5个模型文件:2个clip文件，1 个vae文件, 1个unet文件, 1个lora文件
#其中有两个文件在拷贝后需要改名
cp -r /public/shared-resources/cache/ComfyUI/* /data/ComfyUI/
#如果需要自己下载模型，可以采用如下方式
#modelscope download --model FluxLora/XLabs-AI-flux-RealismLora --local_dir XLabs-AI-flux-RealismLora
#cp XLabs-AI-flux-RealismLora/lora.safetensors /data/ComfyUI/models/loras/flux_realism_lora.safetensors
