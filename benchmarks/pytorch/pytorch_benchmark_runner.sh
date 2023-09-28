#!/usr/bin/bash

set -e

THIS_DIR=$(dirname "$(readlink -f "$0")")

# Run the experiments
vm_mem="12" # VM memory in GB
vm_types=("td" "efi" "sgx")
cpus=(1 2 4 6 8 12 16 20 24 32)

for vm in "${vm_types[@]}"; do
  for cpu in "${cpus[@]}"; do 
    $THIS_DIR/pytorch_benchmark.expect $vm $cpu $vm_mem
  done
done
