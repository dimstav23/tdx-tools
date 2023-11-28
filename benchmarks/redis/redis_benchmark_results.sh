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
  benchmark=$(echo "$file_name" | cut -d'_' -f2)
  thread=$(echo "$file_name" | cut -d'_' -f3)
  if [[ $benchmark == "memtier-benchmark" ]]; then
    # sed to get the first occurence of {number}.{number} (floating point)
    throughput=$(cat "$file" | tail -n 1 | sed -E 's,^[^0-9]*([0-9]+.[0-9]+).*$,\1,')
  elif [[ $benchmark == "redis-benchmark" ]]; then
    # calculate the average throughput
    sum=0
    cnt=0
    while read -r line; do
      val=$(echo "$line" | sed 's/.*://' | sed -E 's,^[^0-9]*([0-9]+.[0-9]+).*$,\1,')
      sum=$(bc <<< "$sum + $val")
      cnt=`expr $cnt + 1`
    done < <(head -n -1 $file) # ignore the last empty line
    throughput=`echo "$sum / $cnt" | bc -l`
  fi
  data["$benchmark,$vm_type,$thread"]=$throughput

  if [[ ${#vm_type} -gt max_vm_type_length ]]; then
    max_vm_type_length=${#vm_type}
  fi
done

benchmarks=$(echo "${!data[@]}" | tr ' ' '\n' | cut -d',' -f1 | sort -u)
vm_types=$(echo "${!data[@]}" | tr ' ' '\n' | cut -d',' -f2 | sort -u)
thread_nums=$(echo "${!data[@]}" | tr ' ' '\n' | cut -d',' -f3 | sort -n -u)

# Output the results to csv
for benchmark in $benchmarks; do
  for vm_type in $vm_types; do
    csv_file="$RESULTS_DIR/"$benchmark"_"$vm_type".csv"
    # write the header of the csv
    printf "Threads," > $csv_file
    for thread in $thread_nums; do
      printf "%s," "$thread" >> $csv_file
    done
    truncate -s-1 $csv_file # remove last comma
    printf "\n" >> $csv_file

    printf "ops/sec," >> $csv_file
    for thread in $thread_nums; do
      key="$benchmark,$vm_type,$thread"
      if [ -n "${data[$key]}" ]; then
        printf "%.8f," "${data[$key]}" >> $csv_file
      else
        printf "," >> $csv_file
      fi
    done
    truncate -s-1 $csv_file # remove last comma
    printf "\n" >> $csv_file
  done
done

# Pretty print the results to stdout
for benchmark in $benchmarks; do
  printf "$benchmark (measurements in ops/sec)\n"
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
      key="$benchmark,$vm_type,$thread"
      if [ -n "${data[$key]}" ]; then
        printf "%.8f\t" "${data[$key]}"
      else
        printf "N/A\t\t"
      fi
    done
    printf "\n"
  done
  printf "\n"
done
