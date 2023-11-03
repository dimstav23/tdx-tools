#!/usr/bin/bash

set -e

THIS_DIR=$(dirname "$(readlink -f "$0")")
DEPS_DIR=$THIS_DIR/deps
PYTORCH_PATCH=$THIS_DIR/../../pytorch/pytorch_benchmark.patch
BLENDER_PATCH=$THIS_DIR/../../blender/blender_benchmark.patch
REDIS_PATCH=$THIS_DIR/../../redis/redis_benchmark.patch
MEMCACHED_PATCH=$THIS_DIR/../../memcached/memcached_benchmark.patch
SQLITE_PATCH=$THIS_DIR/../../sqlite/sqlite_benchmark.patch

# Fetch the git URLs and the stable-commits
. ${THIS_DIR}/../stable-commits

# Create the directory for the dependencies
mkdir -p $DEPS_DIR

# Get gramine dependencies
sudo apt update
sudo apt install build-essential autoconf bison gawk nasm -y
sudo apt install ninja-build pkg-config python3 python3-click -y
sudo apt install python3-jinja2 python3-pip python3-pyelftools wget -y
sudo apt install meson python3-tomli python3-tomli-w -y
sudo apt install libprotobuf-c-dev protobuf-c-compiler protobuf-compiler -y
sudo apt install python3-cryptography python3-pip python3-protobuf -y

# Download, build and install gramine-sgx
cd $DEPS_DIR
if [ -d "gramine" ]; then
  echo "Gramine directory already exists -- skip cloning"
else
  echo "Cloning Gramine"
  git clone ${GRAMINE_GIT_URL}
  cd $DEPS_DIR/gramine
  git checkout ${GRAMINE_COMMIT}
  # Apply the patches for the CI-Examples
  echo "Patching blender..."
  git apply $BLENDER_PATCH
  echo "Patching redis..."
  git apply $REDIS_PATCH
  echo "Patching memcached..."
  git apply $MEMCACHED_PATCH
  echo "Patching sqlite..."
  git apply $SQLITE_PATCH
fi

cd $DEPS_DIR/gramine
if [ -d "build-release" ]; then
  echo "Gramine build-release directory already exists"
  echo "Skipping Gramine build & install phase"
else
  echo "Building and installing Gramine in build-release directory"
  meson setup build-release/ --buildtype=release -Dskeleton=enabled \
  -Ddirect=enabled -Dsgx=enabled --prefix=$PWD/build-release
  ninja -C build-release/
  ninja -C build-release/ install
fi

# Download, build and install gramine-tdx
cd $DEPS_DIR
if [ -d "dkuvaisk.gramine-tdx" ]; then
  echo "Gramine-TDX directory already exists -- skip cloning"
else
  echo "Cloning Gramine-TDX"
  git clone ${GRAMINE_TDX_GIT_URL}
  cd $DEPS_DIR/dkuvaisk.gramine-tdx
  git checkout ${GRAMINE_TDX_COMMIT}
fi

cd $DEPS_DIR/dkuvaisk.gramine-tdx
if [ -d "build-release" ]; then
  echo "Gramine-TDX build-release directory already exists"
  echo "Skipping Gramine-TDX build & install phase"
else
  echo "Building and installing Gramine-TDX in build-release directory"
  meson setup build-release/ --buildtype=release -Dskeleton=enabled \
  -Ddirect=enabled -Dsgx=enabled -Dvm=enabled -Dtdx=enabled \
  --prefix=$PWD/build-release
  ninja -C build-release/
  ninja -C build-release/ install
fi

# Set-up paths for the gramine installation directory
export PATH=$DEPS_DIR/gramine/build-release/bin:$PATH
export PYTHONPATH=$DEPS_DIR/gramine/build-release/lib/python3.10/site-packages:$PYTHONPATH
export PKG_CONFIG_PATH=$DEPS_DIR/gramine/build-release/lib/x86_64-linux-gnu/pkgconfig:$PKG_CONFIG_PATH

# Generate SGX private key if it does not exist
if ! [ -f "$HOME/.config/gramine/enclave-key.pem" ]; then
  echo "Generating SGX private key"
  gramine-sgx-gen-private-key
fi

# Download the gramine-examples, their dependencies and apply the patches
cd $DEPS_DIR
if [ -d "examples" ]; then
  echo "Gramine examples directory already exists -- skip cloning and patching"
else
  echo "Cloning and patching Gramine examples"
  git clone ${GRAMINE_EXAMPLES_GIT_URL}
  cd $DEPS_DIR/examples
  git checkout ${GRAMINE_EXAMPLES_COMMIT}
  git apply $PYTORCH_PATCH
fi

# Setup pytorch example
sudo apt install libnss-mdns libnss-myhostname -y
sudo apt install python3-pip lsb-release -y
pip3 install torchvision pillow
cd $DEPS_DIR/examples/pytorch
if ! [ -f "alexnet-pretrained.pt" ]; then
  echo "Downloading the pre-trained model"
  python3 download-pretrained-model.py
fi

# Build the CI-Examples (if needed)
# blender
sudo apt install libxi6 libxxf86vm1 libxfixes3 libxrender1 -y
cd $DEPS_DIR/gramine/CI-Examples/blender
make
# redis
cd $DEPS_DIR/gramine/CI-Examples/redis
make SGX=1
# memcached
sudo apt install libevent-dev -y
cd $DEPS_DIR/gramine/CI-Examples/memcached
make SGX=1
# sqlite
sudo apt install sqlite3 -y
cd $DEPS_DIR
if [ -d "sqlite" ]; then
  echo "SQLite directory already exists -- skip cloning"
else
  echo "Cloning SQLite"
  git clone ${SQLITE_GIT_URL}
  cd $DEPS_DIR/sqlite
  git checkout ${SQLITE_COMMIT}
  mkdir build
  cd build
  ../configure
  make sqlite3.c # build the SQLite amalgamation
fi
# copy the sqlite3.c, sqlite3.h and kvtest.c files to the benchmark folder
cp $DEPS_DIR/sqlite/build/sqlite3.c $DEPS_DIR/gramine/CI-Examples/sqlite/
cp $DEPS_DIR/sqlite/build/sqlite3.h $DEPS_DIR/gramine/CI-Examples/sqlite/
cp $DEPS_DIR/sqlite/test/kvtest.c $DEPS_DIR/gramine/CI-Examples/sqlite/
cd $DEPS_DIR/gramine/CI-Examples/sqlite
# make SGX=1