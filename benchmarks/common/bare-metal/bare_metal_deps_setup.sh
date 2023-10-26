#!/usr/bin/bash

set -e

THIS_DIR=$(dirname "$(readlink -f "$0")")
DEPS_DIR=$THIS_DIR/deps
PYTORCH_PATCH=$THIS_DIR/../../pytorch/pytorch_benchmark.patch
BLENDER_PATCH=$THIS_DIR/../../blender/blender_benchmark.patch

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
  git clone https://github.com/gramineproject/gramine.git
fi
cd $DEPS_DIR/gramine
git checkout v1.5
if [ -d "build-release" ]; then
  echo "Gramine build-release directory already exists"
  echo "Skipping Gramine build & install phase"
else
  echo "Building and installing Gramine in build-release directory"
  meson setup build-release/ --buildtype=release -Dskeleton=enabled \
  -Ddirect=enabled -Dsgx=enabled --prefix=$PWD/build-release
  ninja -C build-release/
  ninja -C build-release/ install
  # Apply the benchmark patches in the CI-Examples
  # blender
  echo "Patching blender..."
  git apply $BLENDER_PATCH
fi

# Download, build and install gramine-tdx
cd $DEPS_DIR
if [ -d "dkuvaisk.gramine-tdx" ]; then
  echo "Gramine-TDX directory already exists -- skip cloning"
else
  echo "Cloning Gramine-TDX"
  git clone https://github.com/intel-sandbox/dkuvaisk.gramine-tdx.git
fi

cd $DEPS_DIR/dkuvaisk.gramine-tdx
# git checkout 78c2af00dca5eccdd190836c21c7065b11bf2c8b
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

# Download the gramine-examples, their dependencies and apply the patches
sudo apt install libnss-mdns libnss-myhostname -y
sudo apt install python3-pip lsb-release -y
pip3 install torchvision pillow
cd $DEPS_DIR
if [ -d "examples" ]; then
  echo "Gramine examples directory already exists -- skip cloning and patching"
else
  echo "Cloning and patching Gramine examples"
  git clone https://github.com/gramineproject/examples.git
  cd $DEPS_DIR/examples
  git checkout v1.5
  git apply $PYTORCH_PATCH
fi

# Set-up paths for the gramine installation directory
export PATH=$DEPS_DIR/gramine/build-release/bin:$PATH
export PYTHONPATH=$DEPS_DIR/gramine/build-release/lib/python3.10/site-packages:$PYTHONPATH
export PKG_CONFIG_PATH=$DEPS_DIR/gramine/build-release/lib/x86_64-linux-gnu/pkgconfig:$PKG_CONFIG_PATH
cd $DEPS_DIR/examples/pytorch
if ! [ -f "$HOME/.config/gramine/enclave-key.pem" ]; then
  echo "Generating SGX private key"
  gramine-sgx-gen-private-key
fi
if ! [ -f "alexnet-pretrained.pt" ]; then
  echo "Downloading the pre-trained model"
  python3 download-pretrained-model.py
fi
