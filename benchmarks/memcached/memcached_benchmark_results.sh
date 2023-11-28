#!/usr/bin/bash

set -e

THIS_DIR=$(dirname "$(readlink -f "$0")")
RESULTS_DIR=$THIS_DIR/results

# Organize the results
declare -A data

max_vm_type_length=0

for file in $RESULTS_DIR/*.txt; do
  file_name=$(basename "$file")
  vm_type=$(echo "$file_name" | cut -d'_' -f1)
  thread=$(echo "$file_name" | cut -d'_' -f2)
  # sed to get the first occurence of {number}.{number} (floating point)
  time_taken=$(cat "$file" | tail -n 1 | sed -E 's,^[^0-9]*([0-9]+.[0-9]+).*$,\1,')
  data["$vm_type,$thread"]=$time_taken

  if [[ ${#vm_type} -gt max_vm_type_length ]]; then
    max_vm_type_length=${#vm_type}
  fi
done

vm_types=$(echo "${!data[@]}" | tr ' ' '\n' | cut -d',' -f1 | sort -u)
thread_nums=$(echo "${!data[@]}" | tr ' ' '\n' | cut -d',' -f2 | sort -n -u)

# Output the results to csv
for vm_type in $vm_types; do
  csv_file="$RESULTS_DIR/"$vm_type".csv"
  # write the header of the csv
  printf "Threads," > $csv_file
  for thread in $thread_nums; do
    printf "%s," "$thread" >> $csv_file
  done
  truncate -s-1 $csv_file # remove last comma
  printf "\n" >> $csv_file

  printf "ops/sec," >> $csv_file
  for thread in $thread_nums; do
    key="$vm_type,$thread"
    if [ -n "${data[$key]}" ]; then
      printf "%.4f," "${data[$key]}" >> $csv_file
    else
      printf "," >> $csv_file
    fi
  done
  truncate -s-1 $csv_file # remove last comma
  printf "\n" >> $csv_file
done

# Pretty print the results to stdout
header="VM Type\Threads"
if [[ ${#header} -gt max_vm_type_length ]]; then
  max_vm_type_length=${#header}
fi

printf "%-${max_vm_type_length}s\t" "$header"
for thread in $thread_nums; do
  printf "%s\t\t" "$thread"
done
printf "\n"

for vm_type in $vm_types; do
  printf "%-${max_vm_type_length}s\t" "$vm_type"
  for thread in $thread_nums; do
    key="$vm_type,$thread"
    if [ -n "${data[$key]}" ]; then
      printf "%s\t" "${data[$key]}"
    else
      printf "N/A\t\t"
    fi
  done
  printf "\n"
done