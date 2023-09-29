#!/usr/bin/bash

apt update

#Install gramine dependencies
apt install build-essential autoconf bison gawk nasm -y
apt install ninja-build pkg-config python3 python3-click -y
apt install python3-jinja2 python3-pip python3-pyelftools wget -y
apt install meson python3-tomli python3-tomli-w -y
# python3 -m pip install 'meson>=0.56' 'tomli>=1.1.0' 'tomli-w>=0.4.0'
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
export PATH="/usr/local/bin/:$PATH" # to identify the gramine binaries

#Setup the pytorch example
cd /root
git clone https://github.com/gramineproject/examples.git
cd /root/examples
git checkout v1.5
git apply /root/gramine_examples.patch
apt install libnss-mdns libnss-myhostname -y
apt install python3-pip lsb-release -y
pip3 install torchvision pillow
cd /root/examples/pytorch
mkdir results
python3 download-pretrained-model.py
gramine-sgx-gen-private-key
make SGX=1
