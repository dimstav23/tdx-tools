import os
import re

float_match = re.compile("^[-+]?[0-9]*[.][0-9]+$")

# map the variants with their names for the table
variants_label_map = {
  "efi"                   :   "Normal VM",
  "td"                    :   "Intel TDX VM",
  "gramine-sgx"           :   "Gramine-SGX",
  "gramine-tdx"           :   "Gramine-TDX",
  "gramine-vm"            :   "Gramine-VM"
}

# amount of results to consider for taking the average
runs = 10

# VM memory values
vm_memory_setups = [1, 2, 4, 8, 16, 32]

# directory of the results
results_dir = os.path.join(os.path.dirname(os.path.realpath(__file__)), "./results")
if not os.path.exists(results_dir):
  print("results directory not found.")
  exit()

results = {}
# loop over the variants, memory setups and experiment repetitions to gather the results 
for variant in variants_label_map.keys():
  results[variant] = {}
  for vm_mem in vm_memory_setups:
    results[variant][vm_mem] = 0
    for i in range(1, runs + 1):
      # construct the file name
      filename = f"{variant}_{vm_mem}G_{i}.txt"
      filepath = os.path.join(results_dir, filename)
      if not os.path.exists(filepath):
        print(f"Result file {filename} not found in {results_dir}.")
        exit()
      res_file = open(filepath, 'r')
      for line in res_file:
        line = line.strip()
        if variant == "efi" or variant == "td":
          if float_match.match(line):
            # here we just need the row that actually contains just a float value
            results[variant][vm_mem] += float(line)
        else:
          if line.startswith("real"):
            # output format example: real	1m21.903s
            mins = float(line.split('	')[1].split('m')[0])
            secs = float(line.split('m')[1].split('s')[0])
            results[variant][vm_mem] += (mins * 60 + secs)
    # get the average
    results[variant][vm_mem] /= runs

# pretty print a table with the results
    
# print the names of the columns.
print("{:<20} {:<10} {:<10} {:<10} {:<10} {:<10} {:<10}".format('VM Type\VM Memory', '1G', '2G', '4G', '8G', '16G', '32G'))

for variant in variants_label_map.keys():
  print("{:<20} ".format(variants_label_map[variant]), end="")
  for vm_mem in vm_memory_setups:
    print("{:<10.4f} ".format(results[variant][vm_mem]), end="")
  print("") # to implicitly add a new line
