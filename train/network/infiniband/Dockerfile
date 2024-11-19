
# FROM 10.5.1.249/nvidia/pytorch:23.09-py3

FROM nvcr.io/nvidia/cuda:12.0.1-cudnn8-devel-ubuntu20.04
RUN apt update && apt install -y git autoconf automake libtool
RUN apt install -y libibverbs-dev librdmacm-dev rdma-core libibumad-dev
RUN apt install -y libpci-dev
RUN cd /root/ && git clone -b 24.07.0-0.44 https://github.com/linux-rdma/perftest.git
RUN cd /root/perftest && ./autogen.sh && ./configure && make
RUN cd /root/perftest && make install


# docker build . -t 10.5.1.249/bob-base-image/ibperf:24.07.0-0.44-cuda12.0.1-cudnn8-devel-ubuntu20.04