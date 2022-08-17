#!/bin/bash
# pytorch-1.12.0-set-env.sh

export CFLAGS="-D__NEON__"
export USE_CUDA=0
export USE_CUDNN=0
export BUILD_TEST=0
export USE_MKLDNN=0
export USE_DISTRIBUTED=0

