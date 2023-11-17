#!/usr/bin/bash

apt update

#Install gramine dependencies
apt install build-essential autoconf bison gawk nasm numactl -y
apt install ninja-build pkg-config python3 python3-click -y
apt install python3-jinja2 python3-pip python3-pyelftools wget -y
apt install meson python3-tomli python3-tomli-w -y
apt install libprotobuf-c-dev protobuf-c-compiler protobuf-compiler -y
apt install python3-cryptography python3-pip python3-protobuf -y

#Fetch the git URLs and the stable-commits
. /root/stable-commits

#Build and install gramine
cd /root
git clone ${GRAMINE_GIT_URL}
cd /root/gramine
git checkout ${GRAMINE_COMMIT}
meson setup build/ --buildtype=release -Ddirect=enabled -Dsgx=enabled
ninja -C build/
ninja -C build/ install

export PATH="/usr/local/bin/:$PATH" # to identify the gramine binaries
gramine-sgx-gen-private-key

#Get the Gramine examples
cd /root
git clone ${GRAMINE_EXAMPLES_GIT_URL}
cd /root/examples
git checkout ${GRAMINE_EXAMPLES_COMMIT}

#Setup the pytorch example
git apply /root/pytorch_benchmark.patch
apt install libnss-mdns libnss-myhostname -y
apt install python3-pip lsb-release -y
pip3 install torchvision pillow
cd /root/examples/pytorch
mkdir results
python3 download-pretrained-model.py
make SGX=1

# Setup the openvino example
apt install libsm6 libxext6 libgl1 -y
apt install cmake python3 python3-venv -y
cd /root/examples
git apply /root/openvino_benchmark.patch
cd /root/examples/openvino
mkdir results
python3 -m venv openvino_env
source openvino_env/bin/activate
python -m pip install --upgrade pip
pip install openvino-dev[tensorflow,mxnet]==2022.3.1
deactivate
make SGX=1

# Setup the tensorflow example
apt install unzip -y
apt install python3-pip python-is-python3 -y
pip install tensorflow
pip install psutil pandas
pip install future --user
mkdir -p /root/examples/tensorflow
cd /root/examples/tensorflow
mkdir -p results
cp /root/Makefile ./
cp /root/python.manifest.template ./
make distclean
make install-dependencies-ubuntu
make SGX=1

# Apply the benchmark patches in the CI-Examples and build them (if needed)
# blender
apt install libxi6 libxxf86vm1 libxfixes3 libxrender1 -y
cd /root/gramine
git apply /root/blender_benchmark.patch
mkdir -p /root/gramine/CI-Examples/blender/results
cd /root/gramine/CI-Examples/blender
make

# redis
cd /root/gramine
git apply /root/redis_benchmark.patch
mkdir -p /root/gramine/CI-Examples/redis/results
cd /root/gramine/CI-Examples/redis
make SGX=1

# memcached
apt install libevent-dev -y
cd /root/gramine
git apply /root/memcached_benchmark.patch
mkdir -p /root/gramine/CI-Examples/memcached/results
cd /root/gramine/CI-Examples/memcached
make SGX=1

# sqlite-tmpfs
cd /root/gramine/CI-Examples/sqlite
git apply /root/sqlite-tmpfs_benchmark.patch
cp -r /root/gramine/CI-Examples/sqlite /root/gramine/CI-Examples/sqlite-tmpfs
mkdir -p /root/gramine/CI-Examples/sqlite-tmpfs/results
cd /root/gramine/CI-Examples/sqlite-tmpfs
cp /root/sqlite3.c  ./
cp /root/sqlite3.h  ./
# Note: kvtest.c is imported from the sqlite-tmpfs patch
make SGX=1

# sqlite
apt install sqlite3 -y
cd /root/gramine/CI-Examples/sqlite
git checkout Makefile manifest.template # modified by the sqlite-tmpfs patch
git apply /root/sqlite_benchmark.patch
mkdir -p /root/gramine/CI-Examples/sqlite/results
mv /root/sqlite3.c  ./
mv /root/sqlite3.h  ./
mv /root/kvtest.c   ./
make SGX=1

# python
apt install libnss-mdns python3-numpy python3-scipy python-is-python3 -y
cd /root/gramine
git apply /root/python_benchmark.patch
mkdir -p /root/gramine/CI-Examples/python/results
cd /root/gramine/CI-Examples/python
make SGX=1

# lighttpd
apt install build-essential libssl-dev zlib1g-dev libtool-bin wrk -y
cd /root/gramine
git apply /root/lighttpd_benchmark.patch
mkdir -p /root/gramine/CI-Examples/lighttpd/results
cd /root/gramine/CI-Examples/lighttpd
make distclean
make SGX=1
