
# pytorch-pynq-builds
This repository contains wheels (`*.whl` files) of `torch` and `torchvision` packages,
which are built for Pynq-Z2 (ARM Cortex-A9, armv7l) and ZCU-104 (ARM Cortex-A53, aarch64).

Wheels for Pynq-Z2 are built in the following environment:
- Pynq Linux v2.6 (based on Ubuntu 18.04) (rootfs is available at [here](http://www.pynq.io/board.html))
- Python 3.6.5

Wheels for ZCU-104 are built in the following environment:
- Pynq Linux v2.6 (based on Ubuntu 18.04) (rootfs is available at [here](http://www.pynq.io/board.html))
- Python 3.6.5

See [here](./how-to-build-wheels.md) to build wheels using Docker and Pynq rootfs.

## Environment variables for building PyTorch wheels (armv7l)
- PyTorch 1.7.1: See [armv7l/pytorch-1.7.1-set-env.sh](./armv7l/pytorch-1.7.1-set-env.sh)
- PyTorch 1.9.1: See [armv7l/pytorch-1.9.1-set-env.sh](./armv7l/pytorch-1.9.1-set-env.sh)

## Environment variables for building PyTorch wheels (aarch64)
- PyTorch 1.9.1: See [aarch64/pytorch-1.9.1-set-env.sh](./aarch64/pytorch-1.9.1-set-env.sh)

## List of wheel files for PyTorch (armv7l)
- PyTorch 1.7.1: `torch-1.7.0a0-cp36-cp36m-linux_armv7l.whl`
- PyTorch 1.8.1: `torch-1.8.0a0+56b43f4-cp36-cp36m-linux_armv7l.whl`
- PyTorch 1.9.1: `torch-1.9.0a0+gitdfbd030-cp36-cp36m-linux_armv7l.whl`

## List of wheel files for PyTorch (aarch64)
- PyTorch 1.9.1: `torch-1.9.0a0+gitdfbd030-cp36-cp36m-linux_aarch64.whl`

## List of wheel files for TorchVision (armv7l)
- TorchVision 0.8.1: `torchvision-0.8.0a0+45f960c-cp36-cp36m-linux_armv7l.whl`
- TorchVision 0.9.1: `torchvision-0.9.0a0+8fb5838-cp36-cp36m-linux_armv7l.whl`
- TorchVision 0.10.1: `torchvision-0.10.0a0+ca1a620-cp36-cp36m-linux_armv7l.whl`

## List of wheel files for TorchVision (aarch64)
- TorchVision 0.10.1: `torchvision-0.10.0a0+ca1a620-cp36-cp36m-linux_aarch64.whl`

