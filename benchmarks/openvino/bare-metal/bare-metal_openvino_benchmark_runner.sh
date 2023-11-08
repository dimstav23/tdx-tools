#!/usr/bin/bash

set -e

THIS_DIR=$(dirname "$(readlink -f "$0")")
DEPS_DIR=$THIS_DIR/../../common/bare-metal/deps
RESULTS_DIR=$THIS_DIR/../results
GRAMINE_SGX_INSTALL_DIR=$DEPS_DIR/gramine/build-release
GRAMINE_TDX_INSTALL_DIR=$DEPS_DIR/dkuvaisk.gramine-tdx/build-release
BENCHMARK_DIR=$DEPS_DIR/examples/openvino

THREADS=(1 2 4 6 8 12 16 20 24 32)

# time to run each experiment in seconds
EXPERIMENT_TIME=20

pushd $BENCHMARK_DIR

#create temp directory for the results
mkdir -p results

# Run the native case
make clean && make benchmark_app
for THREAD_CNT in "${THREADS[@]}"; do
  KMP_AFFINITY=granularity=fine,noverbose,compact,1,0 numactl --cpubind=0 --membind=0 \
    ./benchmark_app \
    -m model/public/resnet-50-tf/FP16/resnet-50-tf.xml \
    -d CPU -b 1 -t $EXPERIMENT_TIME -hint none \
    -nstreams $THREAD_CNT -nthreads $THREAD_CNT -nireq $THREAD_CNT \
  | tail -n 10 | tee ./results/RN50_native_"$THREAD_CNT"_threads.txt

  KMP_AFFINITY=granularity=fine,noverbose,compact,1,0 numactl --cpubind=0 --membind=0 \
    ./benchmark_app \
    -m model/intel/bert-large-uncased-whole-word-masking-squad-int8-0001/FP16-INT8/bert-large-uncased-whole-word-masking-squad-int8-0001.xml \
    -d CPU -b 1 -t $EXPERIMENT_TIME -hint none \
    -nstreams $THREAD_CNT -nthreads $THREAD_CNT -nireq $THREAD_CNT \
  | tail -n 10 | tee ./results/Bert_native_"$THREAD_CNT"_threads.txt
done

# Preserve the current values of the env variables
CURR_PATH=$PATH
CURR_PYTHONPATH=$PYTHONPATH
CURR_PKG_CONFIG_PATH=$PKG_CONFIG_PATH

# Run the bare-metal (bm) gramine-direct and gramine-sgx case
export PATH=$GRAMINE_SGX_INSTALL_DIR/bin:$CURR_PATH
export PYTHONPATH=$GRAMINE_SGX_INSTALL_DIR/lib/python3.10/site-packages:$CURR_PYTHONPATH
export PKG_CONFIG_PATH=$GRAMINE_SGX_INSTALL_DIR/lib/x86_64-linux-gnu/pkgconfig:$CURR_PKG_CONFIG_PATH
make clean && make SGX=1
for THREAD_CNT in "${THREADS[@]}"; do
  KMP_AFFINITY=granularity=fine,noverbose,compact,1,0 numactl --cpubind=0 --membind=0 \
    gramine-direct benchmark_app \
    -m model/public/resnet-50-tf/FP16/resnet-50-tf.xml \
    -d CPU -b 1 -t $EXPERIMENT_TIME -hint none \
    -nstreams $THREAD_CNT -nthreads $THREAD_CNT -nireq $THREAD_CNT \
  | tail -n 10 | tee ./results/RN50_bm-gramine-direct_"$THREAD_CNT"_threads.txt

  KMP_AFFINITY=granularity=fine,noverbose,compact,1,0 numactl --cpubind=0 --membind=0 \
    gramine-direct benchmark_app \
    -m model/intel/bert-large-uncased-whole-word-masking-squad-int8-0001/FP16-INT8/bert-large-uncased-whole-word-masking-squad-int8-0001.xml \
    -d CPU -b 1 -t $EXPERIMENT_TIME -hint none \
    -nstreams $THREAD_CNT -nthreads $THREAD_CNT -nireq $THREAD_CNT \
  | tail -n 10 | tee ./results/Bert_bm-gramine-direct_"$THREAD_CNT"_threads.txt
done
for THREAD_CNT in "${THREADS[@]}"; do
  KMP_AFFINITY=granularity=fine,noverbose,compact,1,0 numactl --cpubind=0 --membind=0 \
    gramine-sgx benchmark_app \
    -m model/public/resnet-50-tf/FP16/resnet-50-tf.xml \
    -d CPU -b 1 -t $EXPERIMENT_TIME -hint none \
    -nstreams $THREAD_CNT -nthreads $THREAD_CNT -nireq $THREAD_CNT \
  | tail -n 10 | tee ./results/RN50_bm-gramine-sgx_"$THREAD_CNT"_threads.txt

  KMP_AFFINITY=granularity=fine,noverbose,compact,1,0 numactl --cpubind=0 --membind=0 \
    gramine-sgx benchmark_app \
    -m model/intel/bert-large-uncased-whole-word-masking-squad-int8-0001/FP16-INT8/bert-large-uncased-whole-word-masking-squad-int8-0001.xml \
    -d CPU -b 1 -t $EXPERIMENT_TIME -hint none \
    -nstreams $THREAD_CNT -nthreads $THREAD_CNT -nireq $THREAD_CNT \
  | tail -n 10 | tee ./results/Bert_bm-gramine-sgx_"$THREAD_CNT"_threads.txt
done

# Run the gramine-vm and gramine-tdx case
export PATH=$GRAMINE_TDX_INSTALL_DIR/bin:$CURR_PATH
export PYTHONPATH=$GRAMINE_TDX_INSTALL_DIR/lib/python3.10/site-packages:$CURR_PYTHONPATH
export PKG_CONFIG_PATH=$GRAMINE_TDX_INSTALL_DIR/lib/x86_64-linux-gnu/pkgconfig:$CURR_PKG_CONFIG_PATH
make clean && make SGX=1
for THREAD_CNT in "${THREADS[@]}"; do
  export QEMU_CPU_NUM=$THREAD_CNT
  KMP_AFFINITY=granularity=fine,noverbose,compact,1,0 numactl --cpubind=0 --membind=0 \
    gramine-vm benchmark_app \
    -m model/public/resnet-50-tf/FP16/resnet-50-tf.xml \
    -d CPU -b 1 -t $EXPERIMENT_TIME -hint none \
    -nstreams $THREAD_CNT -nthreads $THREAD_CNT -nireq $THREAD_CNT \
  | tail -n 10 | tee ./results/RN50_gramine-vm_"$THREAD_CNT"_threads.txt

  KMP_AFFINITY=granularity=fine,noverbose,compact,1,0 numactl --cpubind=0 --membind=0 \
    gramine-vm benchmark_app \
    -m model/intel/bert-large-uncased-whole-word-masking-squad-int8-0001/FP16-INT8/bert-large-uncased-whole-word-masking-squad-int8-0001.xml \
    -d CPU -b 1 -t $EXPERIMENT_TIME -hint none \
    -nstreams $THREAD_CNT -nthreads $THREAD_CNT -nireq $THREAD_CNT \
  | tail -n 10 | tee ./results/Bert_gramine-vm_"$THREAD_CNT"_threads.txt
done
for THREAD_CNT in "${THREADS[@]}"; do
  export QEMU_CPU_NUM=$THREAD_CNT
  KMP_AFFINITY=granularity=fine,noverbose,compact,1,0 numactl --cpubind=0 --membind=0 \
    gramine-tdx benchmark_app \
    -m model/public/resnet-50-tf/FP16/resnet-50-tf.xml \
    -d CPU -b 1 -t $EXPERIMENT_TIME -hint none \
    -nstreams $THREAD_CNT -nthreads $THREAD_CNT -nireq $THREAD_CNT \
  | tail -n 10 | tee ./results/RN50_gramine-tdx_"$THREAD_CNT"_threads.txt

  KMP_AFFINITY=granularity=fine,noverbose,compact,1,0 numactl --cpubind=0 --membind=0 \
    gramine-tdx benchmark_app \
    -m model/intel/bert-large-uncased-whole-word-masking-squad-int8-0001/FP16-INT8/bert-large-uncased-whole-word-masking-squad-int8-0001.xml \
    -d CPU -b 1 -t $EXPERIMENT_TIME -hint none \
    -nstreams $THREAD_CNT -nthreads $THREAD_CNT -nireq $THREAD_CNT \
  | tail -n 10 | tee ./results/Bert_gramine-tdx_"$THREAD_CNT"_threads.txt
done

mkdir -p $RESULTS_DIR
mv results/* $RESULTS_DIR
rm -rf results

popd
