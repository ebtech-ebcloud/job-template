import os
from datasets import load_dataset
os.environ['HF_ENDPOINT']='https://hf-mirror.com'
dataset = load_dataset("openai/gsm8k", "main")
dataset.save_to_disk("gsm8k/")
