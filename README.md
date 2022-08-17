
# pytorch-pynq-builds
This repository contains wheels (`*.whl` files) of `torch` and `torchvision` packages,
which are built for Pynq-Z2 (ARM Cortex-A9, armv7l), ZCU-104 (ARM Cortex-A53, aarch64), and Ultra96v2 (ARM Cortex-A53, aarch64).

Wheels for Pynq-Z2 are built in the following environment:
1. Pynq Linux v2.6 and Python 3.6.5
  - Pynq Linux v2.6 (based on Ubuntu 18.04) (rootfs is available at [here](http://www.pynq.io/board.html))
  - Python 3.6.5

Wheels for ZCU-104 are built in the following environment:
1. Pynq Linux v2.6 and Python 3.6.5
  - Pynq Linux v2.6 (based on Ubuntu 18.04) (rootfs is available at [here](http://www.pynq.io/board.html))
  - Python 3.6.5
2. Pynq Linux v2.7 and Python 3.8.2
  - Pynq Linux v2.7 (based on Ubuntu 20.04) (rootfs is available at [here](http://www.pynq.io/board.html))
  - Python 3.8.2

Wheels for Ultra96v2 are built in the following environment:
1. Pynq Linux v2.7 and Python 3.8.2
  - Pynq Linux v2.7 (based on Ubuntu 20.04) (rootfs is available at [here](http://www.pynq.io/board.html))
  - Python 3.8.2

See [here](./how-to-build-wheels.md) to build wheels using Docker and Pynq rootfs.

## Environment variables for building PyTorch wheels (Pynq-Z2, Pynq Linux v2.6)
- PyTorch 1.7.1: See [armv7l-pynq-2.6/pytorch-1.7.1-set-env.sh](./armv7l-pynq-2.6/pytorch-1.7.1-set-env.sh)
- PyTorch 1.9.1: See [armv7l-pynq-2.6/pytorch-1.9.1-set-env.sh](./armv7l-pynq-2.6/pytorch-1.9.1-set-env.sh)

## Environment variables for building PyTorch wheels (ZCU-104, Pynq Linux v2.6)
- PyTorch 1.9.1: See [aarch64-pynq-2.6/pytorch-1.9.1-set-env.sh](./aarch64-pynq-2.6/pytorch-1.9.1-set-env.sh)

## Environment variables for building PyTorch wheels (ZCU-104, Pynq Linux v2.7)
- PyTorch 1.10.2: See [aarch64-pynq-2.7/pytorch-1.10.2-set-env.sh](./aarch64-pynq-2.7/pytorch-1.10.2-set-env.sh)
- PyTorch 1.11.0: See [aarch64-pynq-2.7/pytorch-1.11.0-set-env.sh](./aarch64-pynq-2.7/pytorch-1.11.0-set-env.sh)
- PyTorch 1.12.0: See [aarch64-pynq-2.7/pytorch-1.12.0-set-env.sh](./aarch64-pynq-2.7/pytorch-1.12.0-set-env.sh)

## Environment variables for building PyTorch wheels (Ultra96v2, Pynq Linux v2.7)
- PyTorch 1.10.2: See [ultra96v2-pynq-2.7/pytorch-1.10.2-set-env.sh](./ultra96v2-pynq-2.7/pytorch-1.10.2-set-env.sh)

## List of wheel files for PyTorch (Pynq-Z2, Pynq Linux v2.6)
- Wheels are placed under `armv7l-pynq-2.6-pytorch`.
- PyTorch 1.7.1: `torch-1.7.0a0-cp36-cp36m-linux_armv7l.whl`
- PyTorch 1.8.1: `torch-1.8.0a0+56b43f4-cp36-cp36m-linux_armv7l.whl`
- PyTorch 1.9.1: `torch-1.9.0a0+gitdfbd030-cp36-cp36m-linux_armv7l.whl`

## List of wheel files for PyTorch (ZCU-104, Pynq Linux v2.6)
- Wheels are placed under `aarch64-pynq-2.6-pytorch`.
- PyTorch 1.9.1: `torch-1.9.0a0+gitdfbd030-cp36-cp36m-linux_aarch64.whl`

## List of wheel files for TorchVision (Pynq-Z2, Pynq Linux v2.6)
- Wheels are placed under `armv7l-pynq-2.6-torchvision`.
- TorchVision 0.8.1: `torchvision-0.8.0a0+45f960c-cp36-cp36m-linux_armv7l.whl`
- TorchVision 0.9.1: `torchvision-0.9.0a0+8fb5838-cp36-cp36m-linux_armv7l.whl`
- TorchVision 0.10.1: `torchvision-0.10.0a0+ca1a620-cp36-cp36m-linux_armv7l.whl`

## List of wheel files for TorchVision (ZCU-104, Pynq Linux v2.6)
- Wheels are placed under `aarch64-pynq-2.6-torchvision`.
- TorchVision 0.10.1: `torchvision-0.10.0a0+ca1a620-cp36-cp36m-linux_aarch64.whl`

## List of wheel files for PyTorch (ZCU-104, Pynq Linux v2.7)
- Wheels are placed under `aarch64-pynq-2.7-pytorch`.
- PyTorch 1.10.2: `torch-1.10.0a0+git71f889c-cp38-cp38-linux_aarch64.whl`
- PyTorch 1.11.0: `torch-1.11.0a0+gitbc2c6ed-cp38-cp38-linux_aarch64.whl`
- PyTorch 1.12.0: `torch-1.12.0a0+git67ece03-cp38-cp38-linux_aarch64.whl`

## List of wheel files for TorchVision (ZCU-104, Pynq Linux v2.7)
- Wheels are placed under `aarch64-pynq-2.7-torchvision`.
- TorchVision 0.11.3: `torchvision-0.11.0a0+05eae32-cp38-cp38-linux_aarch64.whl`
- TorchVision 0.12.0: `torchvision-0.12.0a0+9b5a3fe-cp38-cp38-linux_aarch64.whl`
- TorchVision 0.13.0: `torchvision-0.13.0a0+da3794e-cp38-cp38-linux_aarch64.whl`

## List of wheel files for PyTorch (Ultra96v2, Pynq Linux v2.7)
- Wheels are placed under `ultra96v2-pynq-2.7-pytorch`.
- PyTorch 1.10.2: `torch-1.10.0a0+git71f889c-cp38-cp38-linux_aarch64.whl`

## List of wheel files for TorchVision (Ultra96v2, Pynq Linux v2.7)
- Wheels are placed under `ultra96v2-pynq-2.7-torchvision`.
- TorchVision 0.11.3: `torchvision-0.11.0a0+05eae32-cp38-cp38-linux_aarch64.whl`

