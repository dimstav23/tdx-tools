#!/usr/bin/bash

set -e

THIS_DIR=$(dirname "$(readlink -f "$0")")
GENERATOR_SCRIPT=$THIS_DIR/generate_plots.py

# blender
python3 $GENERATOR_SCRIPT -d ../blender/results_paper_1/ -a blender -e default -n absolute -x threads -l "upper right" -t blender_single_res
python3 $GENERATOR_SCRIPT -d ../blender/results_paper_1/:../blender/results_paper_2/:../blender/results_paper_3/ -a blender -e default -n absolute -x threads -l "upper right" -t blender
python3 $GENERATOR_SCRIPT -d ../blender/results_paper_1/:../blender/results_paper_2/:../blender/results_paper_3/ -a blender -e default -n absolute -x threads -l "upper right" --error_bar -t blender_error_bars
python3 $GENERATOR_SCRIPT -d ../blender/results_paper_1/:../blender/results_paper_2/:../blender/results_paper_3/ -a blender -e default -n overhead -x threads -l "upper right" -t blender_overhead

# lighttpd
python3 $GENERATOR_SCRIPT -d ../lighttpd/results_paper_1/ -a lighttpd -e 100,10K -n absolute -x threads -l "upper left" -t lighttpd_single_res
python3 $GENERATOR_SCRIPT -d ../lighttpd/results_paper_1/:../lighttpd/results_paper_2/:../lighttpd/results_paper_3/ -a lighttpd -e 100,10K -n absolute -x threads -l "upper left" -t lighttpd
python3 $GENERATOR_SCRIPT -d ../lighttpd/results_paper_1/:../lighttpd/results_paper_2/:../lighttpd/results_paper_3/ -a lighttpd -e 100,10K -n absolute -x threads -l "upper left" --error_bar -t lighttpd_error_bars
python3 $GENERATOR_SCRIPT -d ../lighttpd/results_paper_1/:../lighttpd/results_paper_2/:../lighttpd/results_paper_3/ -a lighttpd -e 100,10K -n overhead -x threads -l "upper left" -t lighttpd_overhead

# python
python3 $GENERATOR_SCRIPT -d ../python/results_paper_1/ -a python -e numpy.dot,scipy.fft.fft2,scipy.linalg.svd -n absolute -x threads -l "upper right" -t python_single_res
python3 $GENERATOR_SCRIPT -d ../python/results_paper_1/:../python/results_paper_2/:../python/results_paper_3/ -a python -e numpy.dot,scipy.fft.fft2,scipy.linalg.svd -n absolute -x threads -l "upper right" -t python
python3 $GENERATOR_SCRIPT -d ../python/results_paper_1/:../python/results_paper_2/:../python/results_paper_3/ -a python -e numpy.dot,scipy.fft.fft2,scipy.linalg.svd -n absolute -x threads -l "upper right" --error_bar -t python_error_bars
python3 $GENERATOR_SCRIPT -d ../python/results_paper_1/:../python/results_paper_2/:../python/results_paper_3/ -a python -e numpy.dot,scipy.fft.fft2,scipy.linalg.svd -n overhead -x threads -l "upper right" -t python_overhead

# pytorch
python3 $GENERATOR_SCRIPT -d ../pytorch/results_paper_1/ -a pytorch -e default -n absolute -x threads -l "upper right" -t pytorch_single_res
python3 $GENERATOR_SCRIPT -d ../pytorch/results_paper_1/:../pytorch/results_paper_2/:../pytorch/results_paper_3/ -a pytorch -e default -n absolute -x threads -l "upper right" -t pytorch
python3 $GENERATOR_SCRIPT -d ../pytorch/results_paper_1/:../pytorch/results_paper_2/:../pytorch/results_paper_3/ -a pytorch -e default -n absolute -x threads -l "upper right" --error_bar -t pytorch_error_bars
python3 $GENERATOR_SCRIPT -d ../pytorch/results_paper_1/:../pytorch/results_paper_2/:../pytorch/results_paper_3/ -a pytorch -e default -n overhead -x threads -l "upper right" -t pytorch_overhead

# openvino
python3 $GENERATOR_SCRIPT -d ../openvino/results_paper_1/ -a openvino -e Bert,RN50 -n absolute -x threads -l "upper left" -t openvino_single_res
python3 $GENERATOR_SCRIPT -d ../openvino/results_paper_1/:../openvino/results_paper_2/:../openvino/results_paper_3/ -a openvino -e Bert,RN50 -n absolute -x threads -l "upper left" -t openvino
python3 $GENERATOR_SCRIPT -d ../openvino/results_paper_1/:../openvino/results_paper_2/:../openvino/results_paper_3/ -a openvino -e Bert,RN50 -n absolute -x threads -l "upper left" --error_bar -t openvino_error_bars
python3 $GENERATOR_SCRIPT -d ../openvino/results_paper_1/:../openvino/results_paper_2/:../openvino/results_paper_3/ -a openvino -e Bert,RN50 -n overhead -x threads -l "upper left" -t openvino_overhead

# sqlite
python3 $GENERATOR_SCRIPT -d ../sqlite/results_paper_1/ -a sqlite -e read,update,read-random,update-random -n absolute -x experiments -l "upper left" -t sqlite_single_res
python3 $GENERATOR_SCRIPT -d ../sqlite/results_paper_1/:../sqlite/results_paper_2/:../sqlite/results_paper_3/ -a sqlite -e read,update,read-random,update-random -n absolute -x experiments -l "upper left" -t sqlite
python3 $GENERATOR_SCRIPT -d ../sqlite/results_paper_1/:../sqlite/results_paper_2/:../sqlite/results_paper_3/ -a sqlite -e read,update,read-random,update-random -n absolute -x experiments -l "upper left" --error_bar -t sqlite_error_bars
python3 $GENERATOR_SCRIPT -d ../sqlite/results_paper_1/:../sqlite/results_paper_2/:../sqlite/results_paper_3/ -a sqlite -e read,update,read-random,update-random -n overhead -x experiments -l "upper left" -t sqlite_overhead

# sqlite-tmpfs
python3 $GENERATOR_SCRIPT -d ../sqlite-tmpfs/results_paper_1/ -a sqlite-tmpfs -e read,update,read-random,update-random -n absolute -x experiments -l "upper left" -t sqlite-tmpfs_single_res
python3 $GENERATOR_SCRIPT -d ../sqlite-tmpfs/results_paper_1/:../sqlite-tmpfs/results_paper_2/:../sqlite-tmpfs/results_paper_3/ -a sqlite-tmpfs -e read,update,read-random,update-random -n absolute -x experiments -l "upper left" -t sqlite-tmpfs
python3 $GENERATOR_SCRIPT -d ../sqlite-tmpfs/results_paper_1/:../sqlite-tmpfs/results_paper_2/:../sqlite-tmpfs/results_paper_3/ -a sqlite-tmpfs -e read,update,read-random,update-random -n absolute -x experiments -l "upper left" --error_bar -t sqlite-tmpfs_error_bars
python3 $GENERATOR_SCRIPT -d ../sqlite-tmpfs/results_paper_1/:../sqlite-tmpfs/results_paper_2/:../sqlite-tmpfs/results_paper_3/ -a sqlite-tmpfs -e read,update,read-random,update-random -n overhead -x experiments -l "upper left" -t sqlite-tmpfs_overhead

# tensorflow
python3 $GENERATOR_SCRIPT -d ../tensorflow/results_paper_1/ -a tensorflow -e Bert,RN50 -n absolute -x threads -l "upper left" -t tensorflow_single_res
python3 $GENERATOR_SCRIPT -d ../tensorflow/results_paper_1/:../tensorflow/results_paper_2/ -a tensorflow -e Bert,RN50 -n absolute -x threads -l "upper left" -t tensorflow
python3 $GENERATOR_SCRIPT -d ../tensorflow/results_paper_1/:../tensorflow/results_paper_2/ -a tensorflow -e Bert,RN50 -n absolute -x threads -l "upper left" --error_bar -t tensorflow_error_bars
python3 $GENERATOR_SCRIPT -d ../tensorflow/results_paper_1/:../tensorflow/results_paper_2/ -a tensorflow -e Bert,RN50 -n overhead -x threads -l "upper left" -t tensorflow_overhead

# redis
python3 $GENERATOR_SCRIPT -d ../redis/results_paper_1/ -a redis  -e GET,SET,LRANGE-300 -n absolute -x threads -l "upper center" -t redis_single_res
python3 $GENERATOR_SCRIPT -d ../redis/results_paper_1/:../redis/results_paper_2/:../redis/results_paper_3/ -a redis -e GET,SET,LRANGE-300 -n absolute -x threads -l "upper center" -t redis
python3 $GENERATOR_SCRIPT -d ../redis/results_paper_1/:../redis/results_paper_2/:../redis/results_paper_3/ -a redis -e GET,SET,LRANGE-300 -n absolute -x threads -l "upper center" --error_bar -t redis_error_bars
python3 $GENERATOR_SCRIPT -d ../redis/results_paper_1/:../redis/results_paper_2/:../redis/results_paper_3/ -a redis -e GET,SET,LRANGE-300 -n overhead -x threads -l "upper center" -t redis_overhead
python3 $GENERATOR_SCRIPT -d ../redis/results_paper_1/ -a redis  -e GET,SET,LRANGE-300 -n absolute -x experiments -l "upper center" -t redis-experiments_single_res
python3 $GENERATOR_SCRIPT -d ../redis/results_paper_1/:../redis/results_paper_2/:../redis/results_paper_3/ -a redis -e GET,SET,LRANGE-300 -n absolute -x experiments -l "upper center" -t redis-experiments
python3 $GENERATOR_SCRIPT -d ../redis/results_paper_1/:../redis/results_paper_2/:../redis/results_paper_3/ -a redis -e GET,SET,LRANGE-300 -n absolute -x experiments -l "upper center" --error_bar -t redis-experiments_error_bars
python3 $GENERATOR_SCRIPT -d ../redis/results_paper_1/:../redis/results_paper_2/:../redis/results_paper_3/ -a redis -e GET,SET,LRANGE-300 -n overhead -x experiments -l "upper center" -t redis-experiments_overhead

# memcached
python3 $GENERATOR_SCRIPT -d ../memcached/results_paper_1/ -a memcached -e default -n absolute -x threads -l "upper left" -t memcached_single_res
python3 $GENERATOR_SCRIPT -d ../memcached/results_paper_1/:../memcached/results_paper_2/:../memcached/results_paper_3/ -a memcached -e default -n absolute -x threads -l "upper left" -t memcached
python3 $GENERATOR_SCRIPT -d ../memcached/results_paper_1/:../memcached/results_paper_2/:../memcached/results_paper_3/ -a memcached -e default -n absolute -x threads -l "upper left" --error_bar -t memcached_single_res
python3 $GENERATOR_SCRIPT -d ../memcached/results_paper_1/:../memcached/results_paper_2/:../memcached/results_paper_3/ -a memcached -e default -n overhead -x threads -l "upper left" -t memcached_overhead

# Combined plots

# Pytorch, Openvino (RN50), TF (Bert) -> 1 plot
python3 $GENERATOR_SCRIPT -d ../pytorch/results_paper_1/:../pytorch/results_paper_2/:../pytorch/results_paper_3/ \
  ../openvino/results_paper_1/:../openvino/results_paper_2/:../openvino/results_paper_3/ \
  ../tensorflow/results_paper_1/:../tensorflow/results_paper_2/ \
  -a pytorch openvino tensorflow -e default RN50 Bert -n absolute -x threads -l "upper right" -t AI_ML_frameworks
python3 $GENERATOR_SCRIPT -d ../pytorch/results_paper_1/:../pytorch/results_paper_2/:../pytorch/results_paper_3/ \
  ../openvino/results_paper_1/:../openvino/results_paper_2/:../openvino/results_paper_3/ \
  ../tensorflow/results_paper_1/:../tensorflow/results_paper_2/:../tensorflow/results_paper_3/ \
  -a pytorch openvino tensorflow -e default RN50 Bert -n absolute -x threads -l "upper right" --error_bar -t AI_ML_frameworks_error_bars

# sqlite, sqlite-tmps -> 1 plot
python3 $GENERATOR_SCRIPT -d ../sqlite/results_paper_1/:../sqlite/results_paper_2/:../sqlite/results_paper_3/ \
  ../sqlite-tmpfs/results_paper_1/:../sqlite-tmpfs/results_paper_2/:../sqlite-tmpfs/results_paper_3/ \
  -a sqlite sqlite-tmpfs -e read,update,read-random,update-random read,update,read-random,update-random -n absolute -x experiments -l "upper left" -t sqlite_merged
python3 $GENERATOR_SCRIPT -d ../sqlite/results_paper_1/:../sqlite/results_paper_2/:../sqlite/results_paper_3/ \
  ../sqlite-tmpfs/results_paper_1/:../sqlite-tmpfs/results_paper_2/:../sqlite-tmpfs/results_paper_3/ \
  -a sqlite sqlite-tmpfs -e read,update,read-random,update-random read,update,read-random,update-random -n absolute -x experiments -l "upper left" --error_bar -t sqlite_merged_error_bars

# # blender, lighttpd, memcached -> 1 plot
# python3 $GENERATOR_SCRIPT -d ../blender/results_paper_1/ ../lighttpd/results_paper_1/ ../memcached/results_paper_1/ \
#   -a blender lighttpd memcached -e default 10K default -n absolute -x threads -l "upper right" -t blender_lighttpd_memcached