. ~/.bashrc;. /home/ubuntu/anaconda3/etc/profile.d/conda.sh ;
conda activate open-mmlab;
cd /home/ubuntu/aws_io/benchmarks/cv/mmclassification;
#export PATH=$PATH:/opt/slurm/bin/;
#
#tools/execute_srun.sh \
#resnet50 \
#8 \
#8 \
#configs/imagenet/resnet50_io_latency.py \
#2 &




#PREFETCH_FACTOR=2
for PREFETCH_FACTOR in {2,4}
do
  SECONDS=0
  N_WORKER=4

  EPOCH_NUM=2
  WORK_DIR=work_dirs/0_ms_trial0_n_worker${N_WORKER}_pt_1_7_prefetch_${PREFETCH_FACTOR}
  /home/ubuntu/anaconda3/envs/open-mmlab/bin/python -u -m torch.distributed.launch \
  --nproc_per_node=8 --master_port=29500 /home/ubuntu/aws_io/benchmarks/cv/mmclassification/tools/train.py \
  configs/imagenet/resnet50_io_latency.py \
  --work-dir=$WORK_DIR \
  --n_workers=$N_WORKER \
  --n_epochs=$EPOCH_NUM \
  --prefetch_factor=$PREFETCH_FACTOR \
  --launcher pytorch

  end_time=$SECONDS
  TIME=$((end_time))
  echo $TIME > "${WORK_DIR}/timetaken"

  python tools/send_metrics.py 8 ${WORK_DIR} resnet50 ${EPOCH_NUM} \
  mmclassification/configs/imagenet/resnet50_io_latency.py > ${WORK_DIR}/metrics
done


#mkdir  work_dirs/0_ms_trial0_n_worker4_pt_1_7
#/home/ubuntu/anaconda3/envs/open-mmlab/bin/python -u -m torch.distributed.launch \
#--nproc_per_node=8 --master_port=29500 /home/ubuntu/aws_io/benchmarks/cv/mmclassification/tools/train.py \
#configs/imagenet/resnet50_io_latency.py --work-dir=work_dirs/0_ms_trial0_n_worker4_pt_1_7 --n_workers=4 \
#--launcher pytorch > work_dirs/0_ms_trial0_n_worker4_pt_1_7/log
#
#
#
#/home/ubuntu/anaconda3/envs/open-mmlab/bin/python -u -m torch.distributed.launch \
#--nproc_per_node=8 --master_port=29500 /home/ubuntu/aws_io/benchmarks/cv/mmclassification/tools/train.py \
#configs/imagenet/resnet50_io_latency.py --work-dir=work_dirs/test --n_workers=4 --launcher pytorch
#
#
#/home/ubuntu/anaconda3/envs/open-mmlab/bin/python -u -m torch.distributed.launch \
#--nproc_per_node=8 --master_port=29500 /home/ubuntu/aws_io/benchmarks/cv/mmclassification/tools/train.py \
#configs/imagenet/resnet50_io_latency.py --work-dir=work_dirs/test --n_workers=4 --launcher pytorch