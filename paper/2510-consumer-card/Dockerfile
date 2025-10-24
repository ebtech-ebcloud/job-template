FROM nvcr.io/nvidia/cuda:12.4.1-devel-ubuntu22.04
# registry-cn-huabei1-internal.ebcloud.com/nvcr.io/nvidia/cuda:12.4.1-devel-ubuntu22.04

# silent mode
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    git \
    curl \
    sudo \
    build-essential \
    libgl1 \
    ninja-build \
    cmake \
    libnuma1 \
    libnuma-dev \
    && rm -rf /var/lib/apt/lists/*

# apt-get install -y libgl1

# install miniconda
RUN curl -LO https://repo.anaconda.com/miniconda/Miniconda3-py312_25.7.0-2-Linux-x86_64.sh && \
    bash Miniconda3-py312_25.7.0-2-Linux-x86_64.sh -b -p /miniconda && \
    rm Miniconda3-py312_25.7.0-2-Linux-x86_64.sh
ENV PATH="/miniconda/bin:$PATH"
RUN conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main && \
    conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r

# setup conda env
RUN conda create -n comfyui python=3.12 -y
WORKDIR /root
RUN git clone --depth 1 https://github.com/comfyanonymous/ComfyUI.git 
WORKDIR /root/ComfyUI/custom_nodes
RUN git clone --depth 1 https://github.com/city96/ComfyUI-GGUF.git
WORKDIR /root/ComfyUI

RUN conda run -n comfyui \
    pip install --no-cache-dir \
    uv \
    -i https://mirror-cn-huabei1-internal.ebcloud.com/repository/pypi/simple && \
    conda run -n comfyui uv pip install torch torchvision torchaudio pyyaml \
    -i https://mirror-cn-huabei1-internal.ebcloud.com/repository/pypi/simple && \
    conda run -n comfyui uv pip install -r /root/ComfyUI/requirements.txt \
    -i https://mirror-cn-huabei1-internal.ebcloud.com/repository/pypi/simple && \
    conda run -n comfyui pip cache purge

#RUN conda create -n hfhub python=3.12 -y
#RUN conda run -n hfhub \
#    pip install --no-cache-dir \ uv \
#    -i https://mirror-cn-huabei1-internal.ebcloud.com/repository/pypi/simple && \
#    conda run -n hfhub uv pip install huggingface-hub==0.25.1 datasets \
#    -i https://mirror-cn-huabei1-internal.ebcloud.com/repository/pypi/simple && \
#    conda run -n hfhub pip cache purge
#
RUN conda create -n sglang python=3.12 -y
RUN conda run -n sglang \
    pip install --no-cache-dir \ uv \
    -i https://mirror-cn-huabei1-internal.ebcloud.com/repository/pypi/simple && \
    conda run -n sglang uv pip install  sglang[all]==0.5.2 \
    -i https://mirror-cn-huabei1-internal.ebcloud.com/repository/pypi/simple && \
    conda run -n sglang pip cache purge


## special compatibility fix for 4090/4090D
RUN apt purge cuda-compat-12-4 -y && \
    ln -f -s /lib/x86_64-linux-gnu/libcuda.so.535.161.08 /lib/x86_64-linux-gnu/libcuda.so.1

RUN /miniconda/bin/conda init --all

# set default apt source to aliyun
RUN sed -i 's/archive.ubuntu.com/mirrors.aliyun.com/g' /etc/apt/sources.list && \
    sed -i 's/security.ubuntu.com/mirrors.aliyun.com/g' /etc/apt/sources.list


RUN apt update && apt install -y \
    libglib2.0-0 \
    openssh-server \
    nano \
    iputils-ping \
    net-tools \
    iproute2 \
    telnet \
    dnsutils \
    traceroute \
    tcpdump \
    wget \
    && rm -rf /var/lib/apt/lists/*

RUN pip install -i https://mirror-cn-huabei1-internal.ebcloud.com/repository/pypi/simple \
    jupyterlab

RUN conda install nb_conda_kernels -y

# enable root ssh login
RUN mkdir -p /etc/ssh && \
    echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config && \
    echo "PermitRootLogin yes" >> /etc/ssh/sshd_config

RUN jupyter server --generate-config && \
    echo "c.ServerApp.terminado_settings = {'shell_command': ['/bin/bash']}" >> /root/.jupyter/jupyter_server_config.py

##COPY download_gsm.py /root/download_gsm.py
#COPY quant_fp4.py /root/quant_fp4.py
#COPY flux.1-dev.py /root/flux.1-dev.py
#COPY flux.1-dev-lora.py /root/flux.1-dev-lora.py
#COPY gsm8k /root/gsm8k
#COPY gsm8k-cot.yaml /root/gsm8k-cot.yaml
#
## docker build --network host -f Dockerfile . -t registry-cn-huabei1-internal.ebcloud.com/job-template/inference-compare:250918-1-vllm0.10.2-sglang0.5.2-diffusers0.35.1-cuda12.4.1-ubuntu22.04
