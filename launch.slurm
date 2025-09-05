#!/bin/bash
#----------------------------------------------------
# Sample Slurm job script
#   for TACC Lonestar6 AMD Milan nodes
#
#   *** MPI Job in Normal Queue ***
# 
# Last revised: October 22, 2021
#
# Notes:
#
#   -- Launch this script by executing
#      "sbatch milan.mpi.slurm" on a Lonestar6 login node.
#
#   -- Use ibrun to launch MPI codes on TACC systems.
#      Do NOT use mpirun or mpiexec.
#
#   -- Max recommended MPI ranks per Milan node: 128
#      (start small, increase gradually).
#
#   -- If you're running out of memory, try running
#      fewer tasks per node to give each task more memory.
#
#----------------------------------------------------

#SBATCH -J 384-439_sptr_mul32         # Job name
#SBATCH -o 384-439_sptr_mul32.o.log   # Name of stdout output file
#SBATCH -e 384-439_sptr_mul32.e.log   # Name of stderr error file
#SBATCH -p normal                     # Queue (partition) name
#SBATCH -N 64                         # Total # of nodes 
#SBATCH -n 128                        # Total # of mpi tasks
#SBATCH -t 06:10:00                   # Run time (hh:mm:ss)
#SBATCH --ntasks-per-node=2           # Task count per node
#SBATCH --cpus-per-task=64            # CPU count per task
#SBATCH --mail-type=all               # Send email at begin and end of job
#SBATCH --mail-user=chenhaoh@utexas.edu

DESIGN=gt3_6t_mul32
MODE=sptr
PARTITION_START=384
PARTITION_END=439

PARAMS="num_workers:64,max_time_in_seconds:21600"

ROOT=/work/10548/chenhaoh/ls6/transopt_cp_models/${DESIGN}_${MODE}
CP_MODEL_DIR=${ROOT}/cp_model
RESPONSE_DIR=${ROOT}/response
mkdir -p ${ROOT}
mkdir -p ${RESPONSE_DIR}

export OMP_NUM_THREADS=64

for ((i=${PARTITION_START}; i<=${PARTITION_END}; i++))
do
  INPUT=${CP_MODEL_DIR}/${DESIGN}_partition_$i.cp_model.textproto
  OUTPUT=${RESPONSE_DIR}/${DESIGN}_partition_$i.response.textproto
  srun --exclusive -N1 -n1 --cpu-bind=cores --mem-bind=local \
	  ./bazel-bin/ortools/sat/sat_runner \
           --input=${INPUT} \
           --output=${OUTPUT} \
           --params=${PARAMS} \
           --stderrthreshold=0 \
           --v=0 &
done

# Required; else script will exit immediately.
wait
