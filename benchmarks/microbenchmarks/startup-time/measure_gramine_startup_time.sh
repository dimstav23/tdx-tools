#!/usr/bin/bash

set -e

THIS_DIR=$(dirname "$(readlink -f "$0")")
DEPS_DIR=$THIS_DIR/../../common/bare-metal/deps
RESULTS_DIR=$THIS_DIR/results
GRAMINE_SGX_INSTALL_DIR=$DEPS_DIR/gramine/build-release
GRAMINE_TDX_INSTALL_DIR=$DEPS_DIR/gramine-tdx/build-release
APP_DIR=$DEPS_DIR/gramine/CI-Examples/helloworld
APP_MANIFEST=helloworld.manifest.template

VM_MEM=(1 2 4 8 16 32)

RUNS=10

pushd $APP_DIR

#create directory for the results
mkdir -p $RESULTS_DIR

# Preserve the current values of the env variables
CURR_PATH=$PATH
CURR_PYTHONPATH=$PYTHONPATH
CURR_PKG_CONFIG_PATH=$PKG_CONFIG_PATH

# Run the bare-metal (bm) gramine-sgx case
export PATH=$GRAMINE_SGX_INSTALL_DIR/bin:$CURR_PATH
export PYTHONPATH=$GRAMINE_SGX_INSTALL_DIR/lib/python3.10/site-packages:$CURR_PYTHONPATH
export PKG_CONFIG_PATH=$GRAMINE_SGX_INSTALL_DIR/lib/x86_64-linux-gnu/pkgconfig:$CURR_PKG_CONFIG_PATH

for MEM in "${VM_MEM[@]}"; do
  git checkout $APP_MANIFEST
  echo "sgx.enclave_size = \""$MEM"G\"" >> $APP_MANIFEST
  make clean && make SGX=1
  for (( i=1; i<=$RUNS; i++ ))
  do
    { time gramine-sgx helloworld; } 2> $RESULTS_DIR/gramine-sgx_${MEM}G_${i}.txt
  done
done

# Run the gramine-vm and gramine-tdx case
export PATH=$GRAMINE_TDX_INSTALL_DIR/bin:$CURR_PATH
export PYTHONPATH=$GRAMINE_TDX_INSTALL_DIR/lib/python3.10/site-packages:$CURR_PYTHONPATH
export PKG_CONFIG_PATH=$GRAMINE_TDX_INSTALL_DIR/lib/x86_64-linux-gnu/pkgconfig:$CURR_PKG_CONFIG_PATH

for MEM in "${VM_MEM[@]}"; do
  git checkout $APP_MANIFEST
  echo "sgx.enclave_size = \""$MEM"G\"" >> $APP_MANIFEST
  make clean && make SGX=1
  for (( i=1; i<=$RUNS; i++ ))
  do
    { time gramine-vm helloworld; } 2> $RESULTS_DIR/gramine-vm_${MEM}G_${i}.txt
    { time gramine-tdx helloworld; } 2> $RESULTS_DIR/gramine-tdx_${MEM}G_${i}.txt
  done
done

git checkout $APP_MANIFEST
popd
