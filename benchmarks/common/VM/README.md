## Benchmark VM-image setup

### Prerequisites:
1. Packages required: `qemu-utils`, `libguestfs-tools`, `expect`
2. Succesffuly built the required ubuntu guest tools (see [here](../../../build/ubuntu-22.04/README.md#build-all)) (you basically need to run the `./pkg-builder build-repo.sh` command as explained there)
3. TDX-enabled host (see [here](../../../build/ubuntu-22.04/README.md#install-tdx-host-packages)). The VMs of this benchmark automation use the OVMF files located in `/usr/share/qemu/` of the host. Please, make sure you have a properly configured the TDX host (e.g., TDX kernel, OVMF/TDVF).

**Note**: 
- kernel needs this patch fur Ubuntu due to `pahole` version: https://github.com/intel/tdx-tools/commit/c6c5a5925b7bffe8589ffedfe8066d44748e595c
- `grub2` fails due to package repositories not found error during building dependencies -- ignored

### Preparation process
1. **Build the guest image**
To build the tdx-enabled guest image with the dependencies of the benchmark applications,
run the following in the current directory:
```
$ sudo ./tdx-guest-stack-with-init-script.sh -s vm_image_init.sh
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
