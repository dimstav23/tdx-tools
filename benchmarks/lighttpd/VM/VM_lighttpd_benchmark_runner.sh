#!/usr/bin/bash

set -e

THIS_DIR=$(dirname "$(readlink -f "$0")")

# Run the experiments
vm_mem="32G" # VM memory
epc_mem="32G" # EPC memory for the VM (only used for sgx)
# vm_types=("td" "efi" "gramine-direct" "gramine-sgx")
vm_types=("td" "efi")
cpus=(1) # lighttpd is single threaded

for vm in "${vm_types[@]}"; do
  for cpu in "${cpus[@]}"; do
    $THIS_DIR/VM_lighttpd_benchmark.expect $vm $cpu $vm_mem $epc_mem
  done
done
