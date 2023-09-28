#!/usr/bin/bash

cd /root
git clone https://github.com/dimstav23/gramine-examples.git
cd /root/gramine-examples
git checkout pytorch_tdx_benchmarking
apt update
apt install libnss-mdns libnss-myhostname -y
apt install python3-pip lsb-release -y
pip3 install torchvision pillow
cd /root/gramine-examples/pytorch
python3 download-pretrained-model.py
