## VM-based benchmark variants

### Prerequisites:
1. Packages required: `qemu-utils`, `libguestfs-tools`, `expect`
2. Succesffuly built the required ubuntu guest tools (see [here](../../../build/ubuntu-22.04/README.md#build-all))
3. TDX-enabled host (see [here](../../../build/ubuntu-22.04/README.md#install-tdx-host-packages)). The VMs of this benchmark automation use the OVMF files located in `/usr/share/qemu/` of the host. Please, make sure you have a properly configured the TDX host (e.g., TDX kernel, OVMF/TDVF).

### Preparation steps
1. **Build the guest image**
To build the tdx-enabled guest image with the dependencies of the pytorch example benchmark,
run the following in the current directory:
```
$ sudo ./tdx-guest-stack-with-init-script.sh -s pytorchexample_init.sh
```
This will create one `.qcow2` image in the current directory with the necessary dependencies installed.

2. **Extract the kernel file**
To extract the kernel file run the following in the current directory:
```
$ dpkg -x <tdx-tools>/build/ubuntu-22.04/guest_repo/linux-image-unsigned-*.deb extracted
$ cp extracted/boot/vmlinuz-* ./vmlinuz
$ rm -rf extracted
```
This will create the `vmlinuz` kernel file in the current directory.

### Execution steps
1. **Benchmark execution**
To execute the benchmark (i.e., the pytorch example with various thread counts in TDX VM and in regular VM),
run the following in the current directory:
```
$ ./pytorch_benchmark_runner.sh
```
This command spawns TDX and regular VMs with the desirable CPU core count and executes the pytorch application.<br>
The results are stored in the `/root/examples/pytorch/results` directory of the guest filesystem.<br>
The filenames are in the `[vm_type]_[numer_of_threads]_threads.txt` format.

2. **Results gathering & printing**
To gather the results from the above execution and pretty-print them in a table,
run the following in the parent directory:
```
$ ./pytorch_benchmark_results.sh
```
This command mounts the image, copies out the results in the `results` folder of the parent directory (created if not existing)
and prints them in `stdout` in a table format.