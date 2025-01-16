#! /bin/bash

# apt-get update && apt-get install -y openssh-client iputils-ping telnet openssh-server

export WORLD_SIZE=${WORLD_SIZE}
export RANK=${RANK}
# export NNODES=${WORLD_SIZE}
export NRANKS=${WORLD_SIZE}
export NODE_RANK=${RANK}
export NPROC_PER_NODE=${PET_NPROC_PER_NODE}

printenv

NWORKERS=$(($NNODES - 1))
echo "WORKER NODES: ${NWORKERS}"
if [ $NWORKERS -le 0 ]; then
    echo "for distributed nccl-tests, NNODES must be greater than 1"
    exit 1
fi

# concat to create worker hostnames
hostname_prefix=${HOSTNAME%%-master-0}
SLOT_PER_NODE=${GPUS_PER_NODE}
N_PROCS=${WORLD_SIZE}
GPUS_PER_SLOT=1
# SLOT_PER_NODE=1
# N_PROCS=${NNODES}
# GPUS_PER_SLOT=${GPUS_PER_NODE}
worker_hostnames="localhost:${SLOT_PER_NODE},"
for i in $(seq 0 $((NWORKERS - 1))); do
    worker_hostnames="${worker_hostnames}${hostname_prefix}-worker-${i}:${SLOT_PER_NODE},"
done
echo "Worker hostnames: ${worker_hostnames}"

# /root/nccl-tests/build/all_reduce_perf -b 512M -e 8G -f 2 -g ${GPUS_PER_NODE}
# mpirun -H ${worker_hostnames} -np ${NNODES} /root/nccl-tests/build/all_reduce_perf -b 512M -e 8G -f 2 -g ${GPUS_PER_NODE}

# mpirun --allow-run-as-root --bind-to socket -H localhost,kubeflow-nccl-test-3-worker-0 -np 2 \
# -x NCCL_ALGO=RING -x NCCL_IB_SL=0 -x NCCL_IB_TC=0 -x NCCL_DEBUG=INFO -x NCCL_DEBUG_SUBSYS=ALL -x NCCL_IB_GDR_LEVEL=2 -x NCCL_IB_QPS_PER_CONNECTION=1 \
# /root/nccl-tests/build/all_reduce_perf -b 512M -e 1G -f 2 -g 8

# mpirun --allow-run-as-root --bind-to none --map-by slot -H localhost:8,kubeflow-nccl-test-3-worker-0:8 -np 16 \
# -x NCCL_DEBUG=INFO -x NCCL_DEBUG_SUBSYS=ALL \
# -x NCCL_ALGO=TREE -x NCCL_IB_SL=0 -x NCCL_IB_TC=0 \
# -x NCCL_IB_GDR_LEVEL=2 -x NCCL_IB_QPS_PER_CONNECTION=4 \
# -x NCCL_IB_GID_INDEX=3 \
# -x NCCL_IB_DISABLE=0 \
# /root/nccl-tests/build/sendrecv_perf -b 512M -e 2G -f 2 -g 1 -w 50 -n 500

echo "HOSTNAME: ${HOSTNAME}"
echo "hostname: $(hostname)"

# run on master node
if [[ ${HOSTNAME} == *"master"* ]]; then

    # wait for all nodes to be ready, check by ssh, report worker status every 10s
    # we use a dict to store worker status
    declare -A worker_status
    ready_workers=0
    while [ $ready_workers -lt $NWORKERS ] ; do
        for i in $(seq 0 $((NWORKERS - 1))); do
            # skip when already ready
            if [ "${worker_status[${i}]}" = "1" ]; then
                continue
            fi
            echo "Checking worker ${hostname_prefix}-worker-${i}"
            if ssh -p 2222 ${hostname_prefix}-worker-${i} "echo 'ready'" &> /dev/null; then
                ready_workers=$((ready_workers + 1))
                worker_status[${i}]="1"
            else
                worker_status[${i}]="0"
            fi
        done
        # report worker status
        echo "Worker status: ${worker_status[*]}"
        if [ $ready_workers -lt $NWORKERS ]; then
            sleep 10
        fi
    done

    echo "All workers are ready, now start testing..."

    # sleep 1000

    # -x NCCL_DEBUG=INFO \
    # -x NCCL_DEBUG_SUBSYS=INIT,NET,GRAPH \
    # use NCCL_ALGO=RING to test the real network bandwidth, TREE method will do some tricks to bus bandwidth.
    # -x NCCL_IGNORE_CPU_AFFINITY=1 \
    export OMPI_MCA_plm_rsh_args="-p 2222"
    mpirun --allow-run-as-root --bind-to none --map-by slot -H ${worker_hostnames} -np ${N_PROCS} \
    -x NCCL_ALGO=ring \
    -x NCCL_SOCKET_IFNAME=bond0 \
    -x NCCL_TIMEOUT=10 \
    -x NCCL_COMM_TIMEOUT=10 \
    -x NCCL_COMPLETION_TIMEOUT=10 \
    -x NCCL_IB_TIMEOUT=10 \
    -x UCX_RC_TIMEOUT=30ms \
    -x NCCL_P2P_TIMEOUT=10 \
    -x NCCL_P2P_NET_TIMEOUT=20 \
    -x NCCL_CONNECT_TIMEOUT=20 \
    -x NCCL_SOCKET_TIMEOUT=10 \
    -x NCCL_SOCKET_CONNECT_RETRY=10 \
    -x NCCL_IB_RETRY_CNT=7 \
    -x NCCL_P2P_RETRY_COUNT=10 \
    -x NCCL_NET_RETRY_COUNT=10 \
    -x UCX_RC_RETRY_COUNT=10 \
    -x NCCL_RETRY_CNT=10 \
    -x NCCL_COMM_RETRY_COUNT=10 \
    -x NCCL_RETRY_WAIT_MS=100 \
    -x NCCL_CONNECT_RETRY_CNT=15 \
    -x NCCL_COMPLETION_RETRY_COUNT=10 \
    -x NCCL_IB_RETRY_CNT=10 \
    -x NCCL_IB_RETRY_COUNT=10 \
    -x NCCL_IB_RX_RETRY_CNT=7 \
    -x NCCL_IB_TX_RETRY_CNT=7 \
    -x NCCL_IB_QPN_RETRY_CNT=10 \
    -x NCCL_ASYNC_RETRY_COUNT=10 \
    -x NCCL_P2P_PXN_RETRY_COUNT=10 \
    -x NCCL_NET_GDR_RETRY_COUNT=10 \
    -x NCCL_IB_TC=106 \
    -x NCCL_BUFFSIZE=67108864 \
    -x NCCL_IB_SL=3 \
    -x NCCL_IB_GID_INDEX=3 \
    -x NCCL_IB_QP_NUM=1000 \
    -x NCCL_IB_TIMEOUT_MS=1000 \
    -x NCCL_IB_RETRY_WAIT_MS=100 \
    -x NCCL_NET_RETRY_WAIT_MS=100 \
    -x NCCL_IB_RETRY_INTERVAL_MS=100 \
    -x NCCL_IB_RETRY_INTERVAL_MAX_MS=1000 \
    -x NCCL_IB_RETRY_INTERVAL_BASE_MS=100 \
    -x NCCL_IB_RETRY_INTERVAL_MAX_MS=1000 \
    -x NCCL_IB_RETRY_INTERVAL_BASE_MS=100 \
    /root/nccl-tests/build/all_reduce_perf -b 512M -e 2G -f 2 -g 1 -w 50 -n 50

    # -mca coll_hcoll_enable 0 \
    # -mca pml ob1 \
    # -mca btl_tcp_if_include bond0 \
    # -mca btl ^openib \
    # -x NCCL_ALGO=RING \
    # -x NCCL_NET_GDR_LEVEL=PXB \
    # -x NCCL_IB_QPS_PER_CONNECTION=4 \
    # -x NCCL_IB_DISABLE=0 \
    # -x NCCL_CROSS_NIC=2 \
    # -x NCCL_MAX_NCHANNELS=32 \
    # -x NCCL_MIN_NCHANNELS=32 \
    # -x NCCL_GRAPH_MIXING_SUPPORT=1 \
    # -x NCCL_TOPO_DUMP_FILE=/root/nccl-tests/nccl-topo.xml \
    # -x NCCL_NVB_DISABLE=0 \
    # -x NCCL_P2P_LEVEL=PXB \
    # -x NCCL_IB_GID_INDEX=3 \
    # -x NCCL_IB_TC=106 \
    # -x NCCL_IB_SL=5 \
    # -x NCCL_DEBUG=INFO \
    # -x NCCL_DEBUG_SUBSYS=ALL \
    # echo "NCCL TOPO FILE:"
    # cat /root/nccl-tests/nccl-topo.xml

    for i in $(seq 0 $((NWORKERS - 1))); do
        worker="${hostname_prefix}-worker-${i}"
        echo "=== RoCE diagnostics for ${worker} ==="
        ssh -p 2222 ${worker} "
            echo '=== RoCE Network Interfaces ==='
            ip -d link show | grep -i roce
            echo '=== RDMA Device Status ==='
            rdma link show
            echo '=== Network Interface Status ==='
            ip link show
            echo '=== Network Routes ==='
            ip route show
            echo '=== PFC Settings ==='
            mlnx_qos -i bond0 --pfc
        "
    done
fi

if [[ ${HOSTNAME} == *"worker"* ]]; then
    # trying to connect to master
    hostname_prefix=${HOSTNAME%%-worker-*}
    while ! ssh -p 2222 ${hostname_prefix}-master-0 "echo 'ready'" &> /dev/null; do
        echo "Waiting for master to be ready"
        sleep 5
    done
    echo "Master is ready, now start testing..."
    
    # wait for master to exit, ssh  will fail if master is not running
    while ssh -p 2222 ${hostname_prefix}-master-0 "echo 'ready'" &> /dev/null; do
        echo "Waiting for master to exit"
        sleep 5
    done
    echo "Master exited, now exit"
fi

    # -x NCCL_IB_HCA=mlx5_4,mlx5_10 \
    # -x NCCL_IB_GID_INDEX=3 \
# -x NCCL_IB_SL=0 -x NCCL_IB_TC=0 
# -x LD_LIBRARY_PATH -x PATH \
# -mca coll_hcoll_enable 0 \
# -mca pml ob1 \
# -mca btl_tcp_if_include eth0 \
# -mca btl ^openib \

