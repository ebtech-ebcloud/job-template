
# FROM 10.5.1.249/nvidia/pytorch:23.09-py3

FROM nvcr.io/nvidia/cuda:12.0.1-cudnn8-devel-ubuntu20.04
RUN apt update && apt install -y git autoconf automake libtool
RUN apt install -y libibverbs-dev librdmacm-dev rdma-core libibumad-dev
RUN apt install -y libpci-dev infiniband-diags net-tools ibverbs-utils
# RUN apt install -y perftest
RUN cd /root/ && git clone -b 24.07.0-0.44 https://github.com/linux-rdma/perftest.git
RUN cd /root/perftest && ./autogen.sh && ./configure && make
RUN cd /root/perftest && make install

RUN apt install -y python3 python3-pip
RUN cd /root/ && git clone -b v2.23.4-1 https://github.com/NVIDIA/nccl.git
RUN cd /root/nccl && make -j src.build NVCC_GENCODE="-gencode arch=compute_80,code=sm_80 -gencode arch=compute_86,code=sm_86 -gencode arch=compute_89,code=sm_89 -gencode arch=compute_90,code=sm_90"

RUN cd /root/ && git clone -b v2.13.8 https://github.com/NVIDIA/nccl-tests.git

ENV DEBIAN_FRONTEND=noninteractive
RUN apt install -y libopenmpi-dev openmpi-bin openmpi-common
RUN apt install -y libtool wget libnuma1 libnuma-dev libhwloc-dev libevent-pthreads-2.1-7 zlib1g-dev zlib1g libfabric-dev

# ucx
RUN cd /root/ && git clone -b v1.17.0 https://github.com/openucx/ucx.git \
    && cd ucx \
    && ./autogen.sh \
    && ./configure --prefix=/opt/hpcx/ucx --enable-optimizations --enable-cma --enable-mt --with-cuda=/usr/local/cuda \
    && make -j $(nproc) \
    && make install


RUN cd /root/ && wget https://download.open-mpi.org/release/open-mpi/v4.1/openmpi-4.1.5.tar.gz
RUN cd /root/ && tar -xzf openmpi-4.1.5.tar.gz
RUN cd /root/openmpi-4.1.5 && ./configure --prefix=/usr/local --enable-static --enable-orterun-prefix-by-default --with-libevent=external --with-hwloc=external --without-verbs --with-libfabric --with-ucx=/opt/hpcx/ucx --with-mxm=no --with-cuda=/usr/local/cuda --enable-openib-udcm --enable-openib-rdmacm
RUN cd /root/openmpi-4.1.5 && make -j all && make install

# RUN pip3 install mpi4py
RUN cd /root/nccl-tests && make MPI=1

# ssh config for mpi
RUN apt-get update && apt-get install -y \
    openssh-server \
    openssh-client \
    && mkdir /run/sshd \
    && echo "StrictHostKeyChecking no" >> /etc/ssh/ssh_config \
    && echo "UserKnownHostsFile /dev/null" >> /etc/ssh/ssh_config


# docker build . -t your.registry/bob-base-image/nccl-test:v2.13.8-nccl2.23.4-ibperf24.07.0-cuda12.0.1-cudnn8-devel-ubuntu20.04-1