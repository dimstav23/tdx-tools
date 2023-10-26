#!/usr/bin/bash

apt update

#Install gramine dependencies
apt install build-essential autoconf bison gawk nasm numactl -y
apt install ninja-build pkg-config python3 python3-click -y
apt install python3-jinja2 python3-pip python3-pyelftools wget -y
apt install meson python3-tomli python3-tomli-w -y
apt install libprotobuf-c-dev protobuf-c-compiler protobuf-compiler -y
apt install python3-cryptography python3-pip python3-protobuf -y

#Build and install gramine
cd /root
git clone https://github.com/gramineproject/gramine.git
cd /root/gramine
git checkout v1.5
meson setup build/ --buildtype=release -Ddirect=enabled -Dsgx=enabled
ninja -C build/
ninja -C build/ install
# Apply the benchmark patches in the CI-Examples and build them (if needed)
# blender
apt install libxi6 libxxf86vm1 libxfixes3 libxrender1 -y
git apply /root/blender_benchmark.patch
mkdir -p /root/gramine/CI-Examples/blender/results

export PATH="/usr/local/bin/:$PATH" # to identify the gramine binaries

#Get the Gramine examples
cd /root
git clone https://github.com/gramineproject/examples.git
cd /root/examples
git checkout v1.5

#Setup the pytorch example
git apply /root/pytorch_benchmark.patch
apt install libnss-mdns libnss-myhostname -y
apt install python3-pip lsb-release -y
pip3 install torchvision pillow
cd /root/examples/pytorch
mkdir results
python3 download-pretrained-model.py
gramine-sgx-gen-private-key
make SGX=1
