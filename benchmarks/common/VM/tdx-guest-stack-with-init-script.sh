#!/usr/bin/bash

set -ex

export LIBGUESTFS_BACKEND=direct

THIS_DIR=$(dirname "$(readlink -f "$0")")

IMG_URL=https://cloud-images.ubuntu.com/jammy/current
CLOUD_IMG=jammy-server-cloudimg-amd64.img
TD_IMG=td-guest-ubuntu-22.04.qcow2
REPO_NAME="guest_repo"
REPO_LOCAL=${THIS_DIR}/../../../build/ubuntu-22.04/${REPO_NAME}
INIT_SCRIPT=""

usage() {
    cat << EOM
Usage: $(basename "$0") [OPTION]...
  -s <init_script>      Script to run as an init phase for the VM.
EOM
}

while getopts ":s:" option; do
    case "${option}" in
        s) INIT_SCRIPT=$OPTARG;;
        *)
            usage
            exit 1
            ;;
    esac
done

if [[ ! -f ${INIT_SCRIPT} ]]; then
    echo "Please provide an existing init script or \
use the default tdx-guest-stack.sh script"
    usage
    exit 1
fi

if [[ ! -d ${REPO_LOCAL} ]] ; then
    echo "${REPO_LOCAL} does not exist, please build it via ../../../build/ubuntu-22.04/build-repo.sh"
    exit 1
fi

if ! command -v "virt-customize" ; then
    echo "virt-customize not found, please install libguestfs-tools"
    exit 1
fi

if [[ ! -f ${CLOUD_IMG} ]] ; then
    wget ${IMG_URL}/${CLOUD_IMG}
fi

# The original image is in qcow2 format already.
cp $CLOUD_IMG $TD_IMG

virt-customize -a ${TD_IMG} --root-password password:123456
qemu-img resize ${TD_IMG} +20G

ARGS=" -a ${TD_IMG} -x"

# Setup guest environments
ARGS+=" --copy-in /etc/environment:/etc"
ARGS+=" --copy-in netplan.yaml:/etc/netplan/"
ARGS+=" --copy-in ${REPO_LOCAL}:/srv/"
ARGS+=" --edit '/etc/ssh/sshd_config:s/#PermitRootLogin prohibit-password/PermitRootLogin yes/'"
ARGS+=" --edit '/etc/ssh/sshd_config:s/PasswordAuthentication no/PasswordAuthentication yes/'"
ARGS+=" --run-command 'growpart /dev/sda 1'"
ARGS+=" --run-command 'resize2fs /dev/sda1'"
ARGS+=" --run-command 'ssh-keygen -A'"
ARGS+=" --run-command 'dpkg -i /srv/${REPO_NAME}/linux-*.deb'"
ARGS+=" --run-command 'systemctl mask pollinate.service'"

# Copy the stable-commits file
ARGS+=" --copy-in ${THIS_DIR}/../stable-commits:/root/"

# Copy the gramine patches
ARGS+=" --copy-in ${THIS_DIR}/../../pytorch/pytorch_benchmark.patch:/root/"
ARGS+=" --copy-in ${THIS_DIR}/../../blender/blender_benchmark.patch:/root/"
ARGS+=" --copy-in ${THIS_DIR}/../../redis/redis_benchmark.patch:/root/"
ARGS+=" --copy-in ${THIS_DIR}/../../memcached/memcached_benchmark.patch:/root/"
ARGS+=" --copy-in ${THIS_DIR}/../../sqlite/sqlite_benchmark.patch:/root/"
ARGS+=" --copy-in ${THIS_DIR}/../../sqlite-tmpfs/sqlite-tmpfs_benchmark.patch:/root/"
ARGS+=" --copy-in ${THIS_DIR}/../../openvino/openvino_benchmark.patch:/root/"

# Copy misc files needed for the benchmarks
ARGS+=" --copy-in ${THIS_DIR}/../bare-metal/deps/sqlite/build/sqlite3.c:/root/"
ARGS+=" --copy-in ${THIS_DIR}/../bare-metal/deps/sqlite/build/sqlite3.h:/root/"
ARGS+=" --copy-in ${THIS_DIR}/../bare-metal/deps/sqlite/test/kvtest.c:/root/"

# Copy the init script and run it after the initial guest setup
ARGS+=" --copy-in ${INIT_SCRIPT}:/root/"
ARGS+=" --memsize 16384" # to avoid running out of memory during the init script exec
ARGS+=" --smp 32" # provide 16 cores for the run scripts to use
ARGS+=" --run-command '/root/${INIT_SCRIPT}'"

echo "${ARGS}"
eval virt-customize "${ARGS}"

