import os
import pandas as pd

variants_label_map = {
  "native"                :   "Native",
  "socat-native"          :   "Native w/ socat",
  "efi"                   :   "Normal VM",
  "td"                    :   "Intel TDX VM",
  "bm-gramine-sgx"        :   "Gramine-SGX",
  "gramine-tdx"           :   "Gramine-TDX",
  "gramine-vm"            :   "Gramine-VM",
  "socat-efi"             :   "Normal VM w/ socat",
  "socat-td"              :   "Intel TDX VM w/ socat"
}

class ResultsLoader:
  def __init__(self, directory):
    self.directory = directory

  def filter_data(self, data, experiments_filter):
    filtered_data = {k: v for k, v in data.items() if k in experiments_filter}
    return filtered_data

  def load_data(self, experiments_filter):
    data = {}
    files = [f for f in os.listdir(self.directory) if f.endswith('.csv')]
    
    for file in sorted(files):
      filepath = os.path.join(self.directory, file)
      filename_parts = file.split('_')

      # Extract the experiment name (if applicable)
      if len(filename_parts) == 2:
        experiment, variant = filename_parts
      else:
        experiment, variant = "default", filename_parts[0]

      # Keep only the variant name
      variant = variant.split('.csv')[0]
      # Replace variant with its label
      if variant in variants_label_map.keys():
        variant = variants_label_map[variant]

      # Read csv file into dataframe
      df = pd.read_csv(filepath, header=None)
      # Transpose df to have threads as index and the values as columns
      df = df.transpose()
      # Set the thread values as indexes
      df.set_index(df.columns[0], inplace=True)
      # Set the first row as column names (Threads, Metric)
      df.columns = df.iloc[0]
      # Remove the first row
      df = df[1:]
      # Convert the thread values to integers
      df.index = df.index.astype(int)

      if experiment not in data:
        data[experiment] = {}
      data[experiment][variant] = df
    
    for experiment in experiments_filter:
      if experiment not in data:
        print(f"Error: Experiment {experiment} does not exist in {self.directory}")
        exit()

    data = self.filter_data(data, experiments_filter)
    
    return data