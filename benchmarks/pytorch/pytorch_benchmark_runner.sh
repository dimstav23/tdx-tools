#!/usr/bin/bash

set -e

THIS_DIR=$(dirname "$(readlink -f "$0")")

# Run the experiments
vm_types=("td" "efi")
cpus=(1 2 4 6 8 12 16 20 24 32)

for vm in "${vm_types[@]}"; do
  for cpu in "${cpus[@]}"; do 
    $THIS_DIR/pytorch_benchmark.expect $vm $cpu
  done
done
