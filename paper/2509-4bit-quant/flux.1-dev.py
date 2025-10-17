import torch
import time
from diffusers import FluxPipeline

from nunchaku import NunchakuFluxTransformer2dModel
from nunchaku.utils import get_precision

precision = get_precision()  #自动按照GPU型号判断数据格式:'int4' or 'fp4' 
transformer = NunchakuFluxTransformer2dModel.from_pretrained(
    f"/public/huggingface-models/nunchaku-tech/nunchaku-flux.1-dev/svdq-{precision}_r32-flux.1-dev.safetensors"
)

pipeline = FluxPipeline.from_pretrained(
    "/public/huggingface-models/black-forest-labs/FLUX.1-dev/", transformer=transformer, torch_dtype=torch.bfloat16
).to("cuda")
t1 = time.time()
image = pipeline("A cat holding a sign that says hello world", num_inference_steps=50, guidance_scale=3.5).images[0]
t2 = time.time()
print("elapsed time:", t2-t1)
image.save(f"flux.1-dev-{precision}.png")
