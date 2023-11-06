#!/usr/bin/bash

set -e

THIS_DIR=$(dirname "$(readlink -f "$0")")
DEPS_DIR=$THIS_DIR/../../common/bare-metal/deps
RESULTS_DIR=$THIS_DIR/../results
GRAMINE_SGX_INSTALL_DIR=$DEPS_DIR/gramine/build-release
GRAMINE_TDX_INSTALL_DIR=$DEPS_DIR/dkuvaisk.gramine-tdx/build-release
BENCHMARK_DIR=$DEPS_DIR/gramine/CI-Examples/sqlite-tmpfs

THREADS=(1)

pushd $BENCHMARK_DIR

#create temp directory for the results
mkdir -p results

# Run the native case
make clean && make kvtest
for THREAD_CNT in "${THREADS[@]}"; do
  sudo mount -t tmpfs -o size=4G tmpfs ./db
  # db init process is embedded in kvtest.c
  numactl --cpunodebind=0 --membind=0 ./kvtest run db/test.db --count 500k --stats \
  | tail -n 4 | tee ./results/read_native_"$THREAD_CNT"_threads.txt
  rm -f db/*
  numactl --cpunodebind=0 --membind=0 ./kvtest run db/test.db --count 500k --stats --random \
  | tail -n 4 | tee ./results/read-random_native_"$THREAD_CNT"_threads.txt
  rm -f db/*
  numactl --cpunodebind=0 --membind=0 ./kvtest run db/test.db --count 500k --stats --update \
  | tail -n 4 | tee ./results/update_native_"$THREAD_CNT"_threads.txt
  rm -f db/*
  numactl --cpunodebind=0 --membind=0 ./kvtest run db/test.db --count 500k --stats --update --random \
  | tail -n 4 | tee ./results/update-random_native_"$THREAD_CNT"_threads.txt
  rm -f db/*
  sudo umount ./db
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
  # db init process is embedded in kvtest.c
  numactl --cpunodebind=0 --membind=0 gramine-direct kvtest run db/test.db --count 500k --stats \
  | tail -n 4 | tee ./results/read_bm-gramine-direct_"$THREAD_CNT"_threads.txt
  numactl --cpunodebind=0 --membind=0 gramine-direct kvtest run db/test.db --count 500k --stats --random \
  | tail -n 4 | tee ./results/read-random_bm-gramine-direct_"$THREAD_CNT"_threads.txt
  numactl --cpunodebind=0 --membind=0 gramine-direct kvtest run db/test.db --count 500k --stats --update \
  | tail -n 4 | tee ./results/update_bm-gramine-direct_"$THREAD_CNT"_threads.txt
  numactl --cpunodebind=0 --membind=0 gramine-direct kvtest run db/test.db --count 500k --stats --update --random \
  | tail -n 4 | tee ./results/update-random_bm-gramine-direct_"$THREAD_CNT"_threads.txt
done
for THREAD_CNT in "${THREADS[@]}"; do
  # db init process is embedded in kvtest.c
  numactl --cpunodebind=0 --membind=0 gramine-sgx kvtest run db/test.db --count 500k --stats \
  | tail -n 4 | tee ./results/read_bm-gramine-sgx_"$THREAD_CNT"_threads.txt
  numactl --cpunodebind=0 --membind=0 gramine-sgx kvtest run db/test.db --count 500k --stats --random \
  | tail -n 4 | tee ./results/read-random_bm-gramine-sgx_"$THREAD_CNT"_threads.txt
  numactl --cpunodebind=0 --membind=0 gramine-sgx kvtest run db/test.db --count 500k --stats --update \
  | tail -n 4 | tee ./results/update_bm-gramine-sgx_"$THREAD_CNT"_threads.txt
  numactl --cpunodebind=0 --membind=0 gramine-sgx kvtest run db/test.db --count 500k --stats --update --random \
  | tail -n 4 | tee ./results/update-random_bm-gramine-sgx_"$THREAD_CNT"_threads.txt
done

# Run the gramine-vm and gramine-tdx case
export PATH=$GRAMINE_TDX_INSTALL_DIR/bin:$CURR_PATH
export PYTHONPATH=$GRAMINE_TDX_INSTALL_DIR/lib/python3.10/site-packages:$CURR_PYTHONPATH
export PKG_CONFIG_PATH=$GRAMINE_TDX_INSTALL_DIR/lib/x86_64-linux-gnu/pkgconfig:$CURR_PKG_CONFIG_PATH
make clean && make SGX=1
for THREAD_CNT in "${THREADS[@]}"; do
  # db init process is embedded in kvtest.c
  export QEMU_CPU_NUM=$THREAD_CNT
  numactl --cpunodebind=0 --membind=0 gramine-vm kvtest run db/test.db --count 500k --stats \
  | tail -n 4 | tee ./results/read_gramine-vm_"$THREAD_CNT"_threads.txt
  numactl --cpunodebind=0 --membind=0 gramine-vm kvtest run db/test.db --count 500k --stats --random \
  | tail -n 4 | tee ./results/read-random_gramine-vm_"$THREAD_CNT"_threads.txt
  numactl --cpunodebind=0 --membind=0 gramine-vm kvtest run db/test.db --count 500k --stats --update \
  | tail -n 4 | tee ./results/update_gramine-vm_"$THREAD_CNT"_threads.txt
  numactl --cpunodebind=0 --membind=0 gramine-vm kvtest run db/test.db --count 500k --stats --update --random \
  | tail -n 4 | tee ./results/update-random_gramine-vm_"$THREAD_CNT"_threads.txt
done
for THREAD_CNT in "${THREADS[@]}"; do
  # db init process is embedded in kvtest.c
  export QEMU_CPU_NUM=$THREAD_CNT
  numactl --cpunodebind=0 --membind=0 gramine-tdx kvtest run db/test.db --count 500k --stats \
  | tail -n 4 | tee ./results/read_gramine-tdx_"$THREAD_CNT"_threads.txt
  numactl --cpunodebind=0 --membind=0 gramine-tdx kvtest run db/test.db --count 500k --stats --random \
  | tail -n 4 | tee ./results/read-random_gramine-tdx_"$THREAD_CNT"_threads.txt
  numactl --cpunodebind=0 --membind=0 gramine-tdx kvtest run db/test.db --count 500k --stats --update \
  | tail -n 4 | tee ./results/update_gramine-tdx_"$THREAD_CNT"_threads.txt
  numactl --cpunodebind=0 --membind=0 gramine-tdx kvtest run db/test.db --count 500k --stats --update --random \
  | tail -n 4 | tee ./results/update-random_gramine-tdx_"$THREAD_CNT"_threads.txt
done

mkdir -p $RESULTS_DIR
mv results/* $RESULTS_DIR
rm -rf results

popd
