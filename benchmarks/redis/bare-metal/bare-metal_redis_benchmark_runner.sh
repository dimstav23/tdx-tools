#!/usr/bin/bash

set -e

THIS_DIR=$(dirname "$(readlink -f "$0")")
DEPS_DIR=$THIS_DIR/../../common/bare-metal/deps
RESULTS_DIR=$THIS_DIR/../results
GRAMINE_SGX_INSTALL_DIR=$DEPS_DIR/gramine/build-release
GRAMINE_TDX_INSTALL_DIR=$DEPS_DIR/dkuvaisk.gramine-tdx/build-release
BENCHMARK_DIR=$DEPS_DIR/gramine/CI-Examples/redis

THREADS=(1) # redis is single threaded

BIND0="numactl --cpunodebind=0 --membind=0"
BIND1="numactl --cpunodebind=1 --membind=1"
REDIS_PORT=6379
FWD_PORT=6378

pushd $BENCHMARK_DIR

#create temp directory for the results
mkdir -p results

function run_redis() {
  echo "Running $1 redis-server..."
  rm -rf *.rdb # remove the leftovers from pervious runs
  $BIND0 $1 ./redis-server &
  if [ "$1" = "gramine-vm" ] || [ "$1" = "gramine-tdx" ]; then
    sleep 5
  else
    while ! lsof -i :$REDIS_PORT &> /dev/null; do
      sleep 1
    done
  fi
}

function run_socat() {
  echo "Running socat..."
  if [ "$1" = "TCP" ]; then
    $BIND0 socat TCP4-LISTEN:$FWD_PORT,reuseaddr,fork,backlog=256 TCP4-CONNECT:localhost:$REDIS_PORT &
  elif [ "$1" = "VSOCK" ]; then
    $BIND0 socat TCP4-LISTEN:$FWD_PORT,reuseaddr,fork,backlog=256 VSOCK-CONNECT:10:$REDIS_PORT &
    sleep 5
  fi
  while ! lsof -i :$FWD_PORT &> /dev/null; do
    sleep 1
  done
}

function run_memtier() {
  echo "Running memtier..."
  $BIND0 memtier_benchmark --port=$1 --protocol=redis --hide-histogram \
  | tail -n 8 | tee ./results/"$2"_"$3"_threads.txt
}

function cleanup() {
  echo "Cleaning up..."
  kill $(jobs -p)
  while lsof -i :$REDIS_PORT &> /dev/null; do
    sleep 1
  done 
  while lsof -i :$FWD_PORT &> /dev/null; do
    sleep 1
  done 
}

# Run the native case
for THREAD_CNT in "${THREADS[@]}"; do
  run_redis ""
  run_memtier $REDIS_PORT native $THREAD_CNT
  cleanup

  run_redis ""
  run_socat TCP
  run_memtier $FWD_PORT socat-native $THREAD_CNT
  cleanup
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
  run_redis "gramine-direct"
  run_memtier $REDIS_PORT bm-gramine-direct $THREAD_CNT
  cleanup

  run_redis "gramine-direct"
  run_socat TCP
  run_memtier $FWD_PORT bm-socat-gramine-direct $THREAD_CNT
  cleanup
done
for THREAD_CNT in "${THREADS[@]}"; do
  run_redis "gramine-sgx"
  run_memtier $REDIS_PORT bm-gramine-sgx $THREAD_CNT
  cleanup

  run_redis "gramine-sgx"
  run_socat TCP
  run_memtier $FWD_PORT bm-socat-gramine-sgx $THREAD_CNT
  cleanup
done

# Run the gramine-vm and gramine-tdx case
export PATH=$GRAMINE_TDX_INSTALL_DIR/bin:$CURR_PATH
export PYTHONPATH=$GRAMINE_TDX_INSTALL_DIR/lib/python3.10/site-packages:$CURR_PYTHONPATH
export PKG_CONFIG_PATH=$GRAMINE_TDX_INSTALL_DIR/lib/x86_64-linux-gnu/pkgconfig:$CURR_PKG_CONFIG_PATH
make clean && make SGX=1
for THREAD_CNT in "${THREADS[@]}"; do
  export QEMU_CPU_NUM=$THREAD_CNT
  run_redis "gramine-vm"
  sleep 10
  run_socat VSOCK
  sleep 5
  run_memtier $FWD_PORT gramine-vm $THREAD_CNT
  cleanup
  sleep 30
done
for THREAD_CNT in "${THREADS[@]}"; do
  export QEMU_CPU_NUM=$THREAD_CNT
  run_redis "gramine-tdx"
  sleep 10
  run_socat VSOCK
  sleep 5
  run_memtier $FWD_PORT gramine-tdx $THREAD_CNT
  cleanup
  sleep 30
done

mkdir -p $RESULTS_DIR
mv results/* $RESULTS_DIR
rm -rf results

popd