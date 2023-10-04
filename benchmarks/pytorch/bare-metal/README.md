## Bare-metal benchmark variants

### Prerequisites:
1. TBD

### Preparation steps
1. To install the dependencies for the native variants of the pytorch example, 
run the following in the current directory:
```
$ ./native_pytorch_benchmark_setup.sh
```
This script installs the dependencies (using `apt`), fetches, builds and installs Gramine and Gramine-TDX and retrieves & patches
the pytorch application. All the repositories are placed in the newly created `deps` directory.

### Execution steps
1. To execute the benchmark (i.e., the pytorch example with various thread counts in all the native variants),
run the following in the current directory:
```
$ ./native_pytorch_benchmark_runner.sh
```
This command executes the pytorch application in all the native variants with the desirable CPU core count.<br>
The results are stored in the `results` directory of the parrent folder.<br>
The filenames are in the `[vm_type]_[numer_of_threads]_threads.txt` format.

2. **Results gathering & printing**
To gather the results from the above execution and pretty-print them in a table,
run the following in the parent directory:
```
$ ./pytorch_benchmark_results.sh
```
This command mounts the image, copies out the results in the `results` folder of the parent directory (created if not existing)
and prints them in `stdout` in a table format.