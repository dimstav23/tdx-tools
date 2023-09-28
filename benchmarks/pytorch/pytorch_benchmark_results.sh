#!/usr/bin/bash

set -e

THIS_DIR=$(dirname "$(readlink -f "$0")")
MOUNTPOINT=$THIS_DIR/tmp_mnt
RESULTS_DIR=$THIS_DIR/results

# Gather the results from the guest image
mkdir -p $MOUNTPOINT
sudo guestmount -a $THIS_DIR/td-guest-ubuntu-22.04.qcow2 -i --ro $MOUNTPOINT

mkdir -p $RESULTS_DIR
sudo bash -c "cp $MOUNTPOINT/root/gramine-examples/pytorch/td_* $RESULTS_DIR"
sudo bash -c "cp $MOUNTPOINT/root/gramine-examples/pytorch/efi_* $RESULTS_DIR"
sudo bash -c "cp $MOUNTPOINT/root/gramine-examples/pytorch/sgx_* $RESULTS_DIR"

sudo umount $MOUNTPOINT
rm -rf $MOUNTPOINT

# Pretty print the results
declare -A data

for file in $RESULTS_DIR/*.txt; do
  file_name=$(basename "$file")
  vm_type=$(echo "$file_name" | cut -d'_' -f1)
  thread=$(echo "$file_name" | cut -d'_' -f2)
  time_taken=$(cat "$file" | cut -d' ' -f1)
  data["$vm_type,$thread"]=$time_taken
done

vm_types=$(echo "${!data[@]}" | tr ' ' '\n' | cut -d',' -f1 | sort -u)
thread_nums=$(echo "${!data[@]}" | tr ' ' '\n' | cut -d',' -f2 | sort -n -u)

printf "VM Type\Threads\t\t"
for thread in $thread_nums; do
  printf "%s\t" "$thread"
done
printf "\n"

for vm_type in $vm_types; do
  printf "%s\t\t\t" "$vm_type"
  for thread in $thread_nums; do
    key="$vm_type,$thread"
    if [ -n "${data[$key]}" ]; then
      printf "%.2f\t" "${data[$key]}"
    else
      printf "N/A\t"
    fi
  done
  printf "\n"
done