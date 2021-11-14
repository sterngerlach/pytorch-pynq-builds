#!/bin/bash
# pytorch-1.9.1-set-env.sh

# Use the following command to set environment variables for building PyTorch:
# $ . set-env-pytorch-build.sh
# Do not use the following command:
# $ set-env-pytorch-build.sh

export CFLAGS="-D__NEON__"
export USE_CUDA=0
export USE_CUDNN=0
export BUILD_TEST=0
export USE_MKLDNN=0
export USE_DISTRIBUTED=0

