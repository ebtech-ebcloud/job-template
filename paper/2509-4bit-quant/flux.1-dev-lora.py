import torch
import time
from diffusers import FluxPipeline

from nunchaku import NunchakuFluxTransformer2dModel
from nunchaku.utils import get_precision

precision = get_precision()  # auto-detect your precision is 'int4' or 'fp4' based on your GPU
transformer = NunchakuFluxTransformer2dModel.from_pretrained(
    f"/public/huggingface-models/nunchaku-tech/nunchaku-flux.1-dev/svdq-{precision}_r32-flux.1-dev.safetensors"
)
pipeline = FluxPipeline.from_pretrained(
    "/public/huggingface-models/black-forest-labs/FLUX.1-dev/", transformer=transformer, torch_dtype=torch.bfloat16
).to("cuda")

### LoRA Related Code ###
transformer.update_lora_params(
    "/public/huggingface-models/aleksa-codes/flux-ghibsky-illustration/lora.safetensors"
)  # Path to your LoRA safetensors, can also be a remote HuggingFace path
transformer.set_lora_strength(1)  # Your LoRA strength here
### End of LoRA Related Code ###

t1 = time.time()
image = pipeline(
    "GHIBSKY style, cozy mountain cabin covered in snow, with smoke curling from the chimney and a warm, inviting light spilling through the windows",  # noqa: E501
    num_inference_steps=50,
    guidance_scale=3.5,
).images[0]
t2 = time.time()
print("elapsed time:", t2-t1)
image.save(f"flux.1-dev-ghibsky-{precision}.png")
