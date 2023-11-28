#!/usr/bin/bash

set -e

THIS_DIR=$(dirname "$(readlink -f "$0")")
MOUNTPOINT=$THIS_DIR/tmp_mnt
VM_RESULT_DIR=$MOUNTPOINT/root/gramine/CI-Examples/sqlite/results
RESULTS_DIR=$THIS_DIR/results_tdx_new_1

# Gather the results from the guest image
mkdir -p $MOUNTPOINT
sudo guestmount -a $THIS_DIR/../common/VM/td-guest-ubuntu-22.04.qcow2 -i --ro $MOUNTPOINT

mkdir -p $RESULTS_DIR
sudo bash -c "cp -r $VM_RESULT_DIR/* $RESULTS_DIR 2>/dev/null || true"

sudo umount $MOUNTPOINT
rm -rf $MOUNTPOINT

# Organize the results
declare -A data

max_vm_type_length=0

for file in $RESULTS_DIR/*.txt; do
  file_name=$(basename "$file")
  operation=$(echo "$file_name" | cut -d'_' -f1)
  vm_type=$(echo "$file_name" | cut -d'_' -f2)
  thread=$(echo "$file_name" | cut -d'_' -f3)
  # get the elapsed time
  time_taken=$(cat "$file" | grep "elapsed time" | sed -E 's,^[^0-9]*([0-9]+.[0-9]+).*$,\1,') 
  data["$operation,$vm_type,$thread"]=$time_taken

  if [[ ${#vm_type} -gt max_vm_type_length ]]; then
    max_vm_type_length=${#vm_type}
  fi
done

operations=$(echo "${!data[@]}" | tr ' ' '\n' | cut -d',' -f1 | sort -u)
vm_types=$(echo "${!data[@]}" | tr ' ' '\n' | cut -d',' -f2 | sort -u)
thread_nums=$(echo "${!data[@]}" | tr ' ' '\n' | cut -d',' -f3 | sort -n -u)

# Output the results to csv
for operation in $operations; do
  for vm_type in $vm_types; do
    csv_file="$RESULTS_DIR/"$operation"_"$vm_type".csv"
    # write the header of the csv
    printf "Threads," > $csv_file
    for thread in $thread_nums; do
      printf "%s," "$thread" >> $csv_file
    done
    truncate -s-1 $csv_file # remove last comma
    printf "\n" >> $csv_file

    printf "Runtime(sec)," >> $csv_file
    for thread in $thread_nums; do
      key="$operation,$vm_type,$thread"
      if [ -n "${data[$key]}" ]; then
        printf "%.4f," "${data[$key]}" >> $csv_file
      else
        printf "," >> $csv_file
      fi
    done
    truncate -s-1 $csv_file # remove last comma
    printf "\n" >> $csv_file
  done
done

# Pretty print the results to stdout
for operation in $operations; do
  printf "$operation\n"
  header="VM Type\Threads"
  if [[ ${#header} -gt max_vm_type_length ]]; then
    max_vm_type_length=${#header}
  fi

  printf "%-${max_vm_type_length}s\t" "$header"
  for thread in $thread_nums; do
    printf "%s\t" "$thread"
  done
  printf "\n"

  for vm_type in $vm_types; do
    printf "%-${max_vm_type_length}s\t" "$vm_type"
    for thread in $thread_nums; do
      key="$operation,$vm_type,$thread"
      if [ -n "${data[$key]}" ]; then
        printf "%s\t" "${data[$key]}"
      else
        printf "N/A\t"
      fi
    done
    printf "\n"
  done
  printf "\n"
done
