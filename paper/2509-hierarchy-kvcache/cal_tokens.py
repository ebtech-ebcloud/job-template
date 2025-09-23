from transformers import AutoTokenizer
import os

# 步骤 1: 定义文件路径列表和模型名称
file_paths = [
    "assets/agent_prompt.txt",
    "assets/conversable_agent.py",
    "assets/agent.py",
]

model_path = os.getenv("MODEL_PATH", "/data/models/Qwen/Qwen3-14B")

# 步骤 2: 使用 AutoTokenizer 加载 tokenizer
try:
    tokenizer = AutoTokenizer.from_pretrained(model_path)
except Exception as e:
    print(f"错误: 无法加载模型 '{model_path}'。请检查模型路径和网络连接。")
    print(e)
    exit()

print(f"使用的模型: {model_path}")
print("=" * 50)

# 步骤 3: 遍历文件列表并进行计数
total_tokens = 0
for file_path in file_paths:
    try:
        # 步骤 4: 从文件中读取文本内容
        with open(file_path, "r", encoding="utf-8") as f:
            text = f.read()

        # 步骤 5: 对读取的文本进行编码
        encoded_input = tokenizer(text)

        # 步骤 6: 统计 token 数量并累加到总数
        token_count = len(encoded_input["input_ids"])
        total_tokens += token_count

        # 打印当前文件的结果
        print(f"文件: {file_path}")
        print("-" * 50)
        # print(f"读取内容: \n{text}")
        print(f"该文件的 token 数量: {token_count}\n")
        print("-" * 50)

    except FileNotFoundError:
        print(f"警告: 文件 '{file_path}' 未找到。跳过该文件。")
        continue  # 跳过当前文件，继续下一个

# 步骤 7: 打印所有文件的总 token 数量
print(f"所有文件的总 token 数量是: {total_tokens}")
