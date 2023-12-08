#!/usr/bin/bash

set -e

THIS_DIR=$(dirname "$(readlink -f "$0")")
GENERATOR_SCRIPT=$THIS_DIR/generate_plots.py

# blender
python3 $GENERATOR_SCRIPT  -d ../blender/results_plot/ -a blender -e default -n absolute -x threads -l "upper right" -t blender

# lighttpd
python3 $GENERATOR_SCRIPT  -d ../lighttpd/results_plot/ -a lighttpd -e 100,10K -n absolute -x threads -t lighttpd

# python
python3 $GENERATOR_SCRIPT  -d ../python/results_plot/ -a python -e numpy.dot,scipy.fft.fft2,scipy.linalg.svd -n absolute -x threads -l "upper right" -t python

# pytorch
python3 $GENERATOR_SCRIPT  -d ../pytorch/results_plot/ -a pytorch -e default -n absolute -x threads -l "upper right" -t pytorch

# openvino
python3 $GENERATOR_SCRIPT  -d ../openvino/results_plot/ -a openvino -e Bert,RN50 -n absolute -x threads -l "upper left" -t openvino

# sqlite
python3 $GENERATOR_SCRIPT  -d ../sqlite/results_plot/ -a sqlite -e read,update,read-random,update-random -n absolute -x experiments -l "upper left" -t sqlite

# sqlite-tmpfs
python3 $GENERATOR_SCRIPT  -d ../sqlite-tmpfs/results_plot/ -a sqlite-tmpfs -e read,update,read-random,update-random -n absolute -x experiments -l "upper left" -t sqlite-tmpfs

# tensorflow
python3 $GENERATOR_SCRIPT  -d ../tensorflow/results_plot/ -a tensorflow -e Bert,RN50 -n absolute -x threads -l "upper left" -t tensorflow

# redis
python3 $GENERATOR_SCRIPT  -d ../redis/results_plot/ -a redis  -e GET,SET,LRANGE-300 -n absolute -x threads -l "upper center" -t redis

# memcached
python3 $GENERATOR_SCRIPT  -d ../memcached/results_plot/ -a memcached -e default -n absolute -x threads -l "upper left" -t memcached

# Combined plots

# Pytorch, Openvino (RN50), TF (Bert) -> 1 plot
python3 $GENERATOR_SCRIPT -d ../pytorch/results_plot/ ../openvino/results_plot/ ../tensorflow/results_plot/ \
  -a pytorch openvino tensorflow -e default RN50 Bert -n absolute -x threads -l "upper right" -t AI_ML_frameworks

# sqlite, sqlite-tmps -> 1 plot
python3 $GENERATOR_SCRIPT -d ../sqlite/results_plot/ ../sqlite-tmpfs/results_plot/ \
  -a sqlite sqlite-tmpfs -e read,update,read-random,update-random read,update,read-random,update-random -n absolute -x experiments -l "upper left" -t sqlite_merged

# blender, lighttpd, memcached -> 1 plot
python3 $GENERATOR_SCRIPT -d ../blender/results_plot/ ../lighttpd/results_plot/ ../memcached/results_plot/ \
  -a blender lighttpd memcached -e default 10K default -n absolute -x threads -l "upper right" -t blender_lighttpd_memcached