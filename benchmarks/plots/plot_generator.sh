#!/usr/bin/bash

set -e

THIS_DIR=$(dirname "$(readlink -f "$0")")
GENERATOR_SCRIPT=$THIS_DIR/generate_plots.py

# blender
python3 $GENERATOR_SCRIPT  -d ../blender/results_plot/ -a blender -t bar -n absolute

# lighttpd
python3 $GENERATOR_SCRIPT  -d ../lighttpd/results_plot/ -a lighttpd -t bar -n absolute

# python
python3 $GENERATOR_SCRIPT  -d ../python/results_plot/ -a python -t bar -n absolute

# pytorch
python3 $GENERATOR_SCRIPT  -d ../pytorch/results_plot/ -a pytorch -t bar -n absolute

# openvino
python3 $GENERATOR_SCRIPT  -d ../openvino/results_plot/ -a openvino -t bar -n absolute

# sqlite
python3 $GENERATOR_SCRIPT  -d ../sqlite/results_plot/ -a sqlite -t bar -n absolute

# sqlite-tmpfs
python3 $GENERATOR_SCRIPT  -d ../sqlite-tmpfs/results_plot/ -a sqlite-tmpfs -t bar -n absolute

# tensorflow
python3 $GENERATOR_SCRIPT  -d ../tensorflow/results_plot/ -a tensorflow -t bar -n absolute

# redis
python3 $GENERATOR_SCRIPT  -d ../redis/results_plot/ -a redis -t bar -n absolute

# memcached
python3 $GENERATOR_SCRIPT  -d ../memcached/results_plot/ -a memcached -t bar -n absolute
