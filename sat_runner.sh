#!/bin/bash

TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")

# Change arguments accordingly.
INPUT=$1
OUTPUT=$2
PARAMS="num_workers:64,max_time_in_seconds=1200"

export LD_LIBRARY_PATH="$CONDA_PREFIX/lib:$LD_LIBRARY_PATH"

bazel build -c opt --linkopt=-Wl,--no-gc-sections --host_linkopt=-Wl,--no-gc-sections --linkopt=-lssp --host_linkopt=-lssp //ortools/sat:sat_runner && \
./bazel-bin/ortools/sat/sat_runner \
  --input=${INPUT} \
  --output=${OUTPUT} \
  --params=${PARAMS} \
  --stderrthreshold=0 \
  --v=0
