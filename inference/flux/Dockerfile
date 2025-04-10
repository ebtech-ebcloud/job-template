FROM registry-cn-huabei1-internal.ebcloud.com/nvcr.io/nvidia/cuda:12.4.1-cudnn-devel-ubuntu22.04

RUN apt update && \
    apt install -y \
    	python3 \
    	python3.10-venv \
    	git \
    	libgl1-mesa-glx \
    	libglib2.0-0 \
    	vim && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

RUN cd /root && git clone https://github.com/black-forest-labs/flux.git
RUN cd /root/flux && python3 -m venv .venv
RUN cd /root/flux && . .venv/bin/activate && \
    pip install -e '.[all,tensorrt]' -i https://mirror-cn-huabei1-internal.ebcloud.com/repository/pypi/simple && \
    pip cache purge

# use local repos
RUN sed -i 's/from_pretrained(/from_pretrained(\"\/public\/huggingface-models\/\" + /g' /root/flux/src/flux/modules/conditioner.py
RUN sed -i 's/Falconsai/\/public\/huggingface-models\/Falconsai/g' /root/flux/demo_gr.py

# allow remote access
RUN sed -i 's/launch(/launch(server_name=\"0.0.0.0\",show_api=False,ssl_verify=False,/g' /root/flux/demo_gr.py
# work around for gradio_client: skip additionalProperties check 
RUN sed -i 's/if \"additional/if False and \"additional/g' /root/flux/.venv/lib/python3.10/site-packages/gradio_client/utils.py

