import os
import requests
import json
import time
from typing import List, Dict


def load_file_content(file_path: str) -> str:
    """从文件中加载内容。"""
    if not os.path.exists(file_path):
        raise FileNotFoundError(f"文件 '{file_path}' 不存在。")
    with open(file_path, "r", encoding="utf-8") as f:
        return f.read().strip()


def create_stream_request(
    messages: List[Dict[str, str]], model: str = "gpt-4o"
) -> dict:
    """构造一个用于流式请求的API请求体。"""
    return {
        "model": model,
        "messages": messages,
        "temperature": 0.7,
        # "max_completion_tokens": 500,
        "stream": True,  # 启用流式传输
    }


def send_and_time_stream_request(api_url: str, request_data: dict, api_key: str):
    """
    发送流式请求并统计第一个 chunk 返回所需的时间。

    Args:
        api_url: API 的端点URL。
        request_data: 包含请求数据的字典。
        api_key: API 密钥。
    """
    headers = {"Content-Type": "application/json", "Authorization": f"Bearer {api_key}"}

    print("发送流式请求...")
    start = time.perf_counter()
    first_chunk_time = None
    full_response_content = ""

    try:
        # 使用 stream=True 发送请求
        with requests.post(
            api_url, headers=headers, json=request_data, stream=True
        ) as response:
            response.raise_for_status()  # 检查HTTP错误

            first_chunk_received = False

            # 迭代响应的行
            for line in response.iter_lines():
                if line:
                    # 解码行并处理
                    decoded_line = line.decode("utf-8")
                    if decoded_line.startswith("data:"):
                        # 解析JSON数据
                        json_str = decoded_line[len("data:") :].strip()
                        if json_str == "[DONE]":
                            print("\n请求完成。")
                            break

                        try:
                            chunk = json.loads(json_str)

                            # 仅统计第一个 chunk
                            if not first_chunk_received:
                                first_chunk_time = time.perf_counter() - start
                                print(
                                    f"\n--- 第一个 chunk 在 {first_chunk_time:.4f} 秒后返回。---"
                                )
                                print("-" * 40)
                                first_chunk_received = True

                            delta_content = (
                                chunk.get("choices", [{}])[0]
                                .get("delta", {})
                                .get("content")
                                or ""
                            )
                            full_response_content += delta_content

                        except json.JSONDecodeError:
                            print(f"无法解析JSON: {json_str}")

    except requests.exceptions.RequestException as e:
        print(f"请求失败: {e}")

    # 循环结束后，记录总耗时
    total_time = time.perf_counter() - start

    # 打印最终统计结果
    print("--- 统计结果 ---")
    if first_chunk_time is not None:
        print(f"首个分块返回时间 (TTFT): {first_chunk_time:.4f} 秒")
    print(f"总完成时间: {total_time:.4f} 秒")
    print(f"总返回长度: {len(full_response_content)}")
    return full_response_content


if __name__ == "__main__":
    PORT = os.getenv("PORT", "8000")
    # 配置 API 端点和密钥
    API_URL = f"http://localhost:{PORT}/v1/chat/completions"
    API_KEY = os.getenv("API_KEY", "")
    MODEL_NAME = os.getenv("MODEL_NAME", "Qwen/Qwen3-14B")

    # 构造初始信息
    messages = []
    system_prompt_file = "assets/agent_prompt.txt"
    try:
        system_prompt = load_file_content(system_prompt_file)
        messages.append({"role": "system", "content": system_prompt})
    except FileNotFoundError as e:
        print(e)
        exit()

    # --- 构造第一轮对话 ---
    print("--- 开始第一轮对话 ---")

    first_round_file = "assets/conversable_agent.py"
    first_round_user_prompt = "详细分析这段代码中的设计思想"

    try:
        content = load_file_content(first_round_file)
        messages.append(
            {"role": "user", "content": first_round_user_prompt + "\n\n" + content}
        )
    except FileNotFoundError as e:
        print(e)
        exit()

    # 构造并发送第一轮请求
    first_req = create_stream_request(messages, MODEL_NAME)
    first_resp = send_and_time_stream_request(API_URL, first_req, API_KEY)

    # 将模型的第一轮回复添加到对话历史中
    if first_resp:
        messages.append({"role": "assistant", "content": first_resp})

    # --- 第二轮对话 ---
    print("\n--- 开始第二轮对话 ---")
    second_round_file = "assets/agent.py"
    second_round_user_prompt = "基于这段代码，对之前的分析结果做进一步的补充和完善"

    # 构造第二轮消息列表
    try:
        content = load_file_content(second_round_file)
        messages.append(
            {"role": "user", "content": second_round_user_prompt + "\n\n" + content}
        )
    except FileNotFoundError as e:
        print(e)
        exit()

    # 构造并发送第二轮请求
    second_req = create_stream_request(messages, MODEL_NAME)
    _ = send_and_time_stream_request(API_URL, second_req, API_KEY)
