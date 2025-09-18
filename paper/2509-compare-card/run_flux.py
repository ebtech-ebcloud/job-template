
import torch
from diffusers import FluxPipeline
import os

#  BF16 版本的模型
pipe = FluxPipeline.from_pretrained("/public/huggingface-models/black-forest-labs/FLUX.1-dev", torch_dtype=torch.bfloat16)

#  fp8 版本的模型
# pipe = FluxPipeline.from_pretrained("/public/shared-resources/models/ebcloud/FLUX.1-dev-torchao-fp8", torch_dtype=torch.bfloat16, use_safetensors=False)

if os.environ.get("CPU_OFFLOAD") == "1":
    # 4090 上，对于 BF16 版本的模型，需要开启 cpu offload
    pipe.enable_model_cpu_offload()
else:
    pipe.to("cuda")

prompt = "A cat holding a sign that says hello world"
image = pipe(
    prompt,
    height=1024,
    width=1024,
    guidance_scale=3.5,
    num_inference_steps=50,
    max_sequence_length=512,
    generator=torch.Generator("cpu").manual_seed(0)
).images[0]
image.save("flux-dev.png")