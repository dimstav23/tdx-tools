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
meson setup build/ --buildtype=release -Ddirect=enabled -Dsgx=enabled
ninja -C build/
ninja -C build/ install

#Setup the pytorch example
cd /root
git clone https://github.com/dimstav23/gramine-examples.git
cd /root/gramine-examples
git checkout pytorch_tdx_benchmarking
apt install libnss-mdns libnss-myhostname -y
apt install python3-pip lsb-release -y
pip3 install torchvision pillow
cd /root/gramine-examples/pytorch
python3 download-pretrained-model.py
gramine-sgx-gen-private-key
make SGX=1
