#!/bin/bash
# pytorch-1.8.1-set-env.sh

# Use the following command to set environment variables for building PyTorch:
# $ . pytorch-1.8.1-set-env.sh
# Do not use the following command:
# $ pytorch-1.8.1-set-env.sh

export CFLAGS="-mfpu=neon -D__NEON__"
export USE_CUDA=0
export USE_CUDNN=0
export BUILD_TEST=0
export USE_MKLDNN=0
export USE_DISTRIBUTED=0

