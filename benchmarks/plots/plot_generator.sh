#!/usr/bin/bash

set -e

THIS_DIR=$(dirname "$(readlink -f "$0")")
GENERATOR_SCRIPT=$THIS_DIR/generate_plots.py

# blender
python3 $GENERATOR_SCRIPT  -d ../blender/results_plot/ -a blender -t individual -n absolute -x threads -l "upper right"

# lighttpd
python3 $GENERATOR_SCRIPT  -d ../lighttpd/results_plot/ -a lighttpd -t group -n absolute -x threads

# python
python3 $GENERATOR_SCRIPT  -d ../python/results_plot/ -a python -t group -n absolute -x threads -l "upper right"

# pytorch
python3 $GENERATOR_SCRIPT  -d ../pytorch/results_plot/ -a pytorch -t individual -n absolute -x threads -l "upper right"

# openvino
python3 $GENERATOR_SCRIPT  -d ../openvino/results_plot/ -a openvino -t group -n absolute -x threads -l "upper left"

# sqlite
python3 $GENERATOR_SCRIPT  -d ../sqlite/results_plot/ -a sqlite -t individual -n absolute -x experiments -l "upper left"

# sqlite-tmpfs
python3 $GENERATOR_SCRIPT  -d ../sqlite-tmpfs/results_plot/ -a sqlite-tmpfs -t individual -n absolute -x experiments -l "upper left"

# tensorflow
python3 $GENERATOR_SCRIPT  -d ../tensorflow/results_plot/ -a tensorflow -t group -n absolute -x threads -l "upper left"

# redis
python3 $GENERATOR_SCRIPT  -d ../redis/results_plot/ -a redis -n absolute  -t group -e GET,SET,LRANGE-300 -x threads -l "upper center"

# memcached
python3 $GENERATOR_SCRIPT  -d ../memcached/results_plot/ -a memcached -t individual -n absolute -x threads -l "upper left"
