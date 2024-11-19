#! /bin/bash

# set -x

# ib ping localhost

echo ""
echo "================================================"
echo "============ ib devices ========================"
echo "================================================"
echo ""

# get ib device name
available_ib_devices=$(ibv_devices | tail -n +3 | awk -F' ' '{print $1}' | grep -v bond)
echo "available ib devices:"
echo "$available_ib_devices"

# random select one
MY_IB_DEVICE=$(echo $available_ib_devices | tr ' ' '\n' | shuf -n 1)
MY_IB_DEV_RATE=$(ibstat $MY_IB_DEVICE | grep "Rate" | awk -F' ' '{print $2}')
echo "selected ib device: $MY_IB_DEVICE, rate: $MY_IB_DEV_RATE Gb/s"

echo ""
echo "================================================"
echo "============ ib bandwidth test ================="
echo "================================================"
echo ""

# **CAUTION**: only works with two nodes
# if master node, run ib_send_bw server side
if [[ $(hostname) == *"master"* ]]; then
    echo "master node, start ib_send_bw server side ..."
    ib_send_bw --report_gbit -d $MY_IB_DEVICE -i 1 -a --CPU-freq
else
    echo "worker node, start ib_send_bw client side ..."
    ib_send_bw --report_gbit -d $MY_IB_DEVICE -i 1 -a --CPU-freq $MASTER_ADDR 
fi


