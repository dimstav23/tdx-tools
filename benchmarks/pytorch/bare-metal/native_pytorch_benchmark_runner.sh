#!/usr/bin/bash

set -e

THIS_DIR=$(dirname "$(readlink -f "$0")")
DEPS_DIR=$THIS_DIR/deps
RESULTS_DIR=$THIS_DIR/../results
GRAMINE_SGX_INSTALL_DIR=$DEPS_DIR/gramine/build-release
GRAMINE_TDX_INSTALL_DIR=$DEPS_DIR/dkuvaisk.gramine-tdx/build-release
BENCHMARK_DIR=$DEPS_DIR/examples/pytorch
VM_MEM=24G

THREADS=(1 2 4 6 8 12 16 20 24 32)

pushd $BENCHMARK_DIR

#create temp directory for the results
mkdir -p results

# Run the native case
for THREAD_CNT in "${THREADS[@]}"; do
  export OMP_NUM_THREADS=$THREAD_CNT
  python3 pytorchexample.py $THREAD_CNT native
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
  export OMP_NUM_THREADS=$THREAD_CNT
  gramine-direct ./pytorch pytorchexample.py $THREAD_CNT bm-gramine-direct
done
for THREAD_CNT in "${THREADS[@]}"; do
  export OMP_NUM_THREADS=$THREAD_CNT
  gramine-sgx ./pytorch pytorchexample.py $THREAD_CNT bm-gramine-sgx
done

# Run the gramine-vm and gramine-tdx case
export PATH=$GRAMINE_TDX_INSTALL_DIR/bin:$CURR_PATH
export PYTHONPATH=$GRAMINE_TDX_INSTALL_DIR/lib/python3.10/site-packages:$CURR_PYTHONPATH
export PKG_CONFIG_PATH=$GRAMINE_TDX_INSTALL_DIR/lib/x86_64-linux-gnu/pkgconfig:$CURR_PKG_CONFIG_PATH
make clean && make SGX=1
for THREAD_CNT in "${THREADS[@]}"; do
  export QEMU_CPU_NUM=$THREAD_CNT
  export QEMU_MEM_SIZE=$VM_MEM
  export OMP_NUM_THREADS=$THREAD_CNT
  gramine-vm ./pytorch pytorchexample.py $THREAD_CNT gramine-vm
done
for THREAD_CNT in "${THREADS[@]}"; do
  export QEMU_CPU_NUM=$THREAD_CNT
  export QEMU_MEM_SIZE=$VM_MEM
  export OMP_NUM_THREADS=$THREAD_CNT
  gramine-tdx ./pytorch pytorchexample.py $THREAD_CNT gramine-tdx
done

mkdir -p $RESULTS_DIR
mv results/* $RESULTS_DIR
rm -rf results

popd
