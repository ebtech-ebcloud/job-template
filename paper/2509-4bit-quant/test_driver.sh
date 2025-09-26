python -u -m torch.distributed.run --nproc_per_node=8 --rdzv_endpoint localhost:6000  --rdzv_backend c10d  all_reduce_bench.py
for((i=0; i<8; i++)
do
export CUDA_VISIBLE_DEVICES=$i
python3 mamf-finder.py  --m_range 0 20480 256 --n 4096 --k 4096 --output_file=$(date +"%Y-%m-%d-%H:%M:%S").txt
done

