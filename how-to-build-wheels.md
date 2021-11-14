
# How to build wheels of PyTorch and TorchVision for Pynq-Z2 and ZCU-104

I tested under the following environments:
- Ubuntu 20.04.3 LTS
- Docker 20.10.10 (build b485636)
- GNU parted 3.3
- QEMU (qemu-arm, qemu-aarch64) 4.2.1
- Pynq Linux v2.6 (based on Ubuntu 18.04)
- Intel Xeon E5-1620 @3.7GHz x4
- 128GB RAM

## Setup

First, install Docker by following the instructions in the official website:
- https://docs.docker.com/engine/install/ubuntu/

Then, download the Pynq rootfs (zip archive) from the following URL:
In this page, I am going to build PyTorch and TorchVision wheels for Pynq-Z2, which has the 32-bit ARM Cortex-A9 processor.
So I choose the link `PYNQ rootfs arm v2.6` to download the Pynq v2.6 rootfs for armv7l architecture.
If you want to build wheels for ZCU-104, choose the link `PYNQ rootfs aarch64 v2.6` and download the Pynq v2.6 rootfs for aarch64 architecture.
- http://www.pynq.io/board

Extract the zip archive you downloaded (`pynq_rootfs_arm.zip` in the following example):
```
$ zipinfo pynq_rootfs_arm.zip
Archive:  pynq_rootfs_arm.zip
Zip file size: 1923303886 bytes, number of entries: 1
-rw-r--r--  3.0 unx 7516192768 bx defN 20-Oct-20 03:56
bionic.arm.2.6.0_2020_10_19.img
1 file, 7516192768 bytes uncompressed, 1923303511 bytes compressed:  74.4%

$ unzip pynq_rootfs_arm.zip
$ ls -lh bionic.arm.2.6.0_2020_10_19.img
-rw-r--r-- 1 stern stern 7.0G May 15 23:00 bionic.arm.2.6.0_2020_10_19.img
```

Install the GNU parted (partitioning tool) using `apt`:
```
$ sudo apt update
$ sudo apt install parted

$ parted --version
parted (GNU parted) 3.3
Copyright (C) 2019 Free Software Foundation, Inc.
License GPLv3+: GNU GPL version 3 or later <https://gnu.org/licenses/gpl.html>.
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.

Written by <http://git.debian.org/?p=parted/parted.git;a=blob_plain;f=AUTHORS>.
```

## Creating the image file for Docker

List the partitions in the Pynq rootfs image file above (`bionic.arm.2.6.0_2020_10_19.img` in the following example):
```
$ sudo parted bionic.arm.2.6.0_2020_10_19.img unit B print
Model:  (file)
Disk /mnt/hdd/pynq_rootfs/bionic.arm.2.6.0_2020_10_19.img: 7516192768B
Sector size (logical/physical): 512B/512B
Partition Table: msdos
Disk Flags:

Number  Start       End          Size         Type     File system  Flags
 1      1048576B    105906175B   104857600B   primary  fat16        boot, lba
 2      105906176B  7516192767B  7410286592B  primary  ext4
```

Create the directory on which the Pynq rootfs is mounted (`/mnt/pynq_image` in the following example):
```
$ sudo mkdir -p /mnt/pynq_image
```

Mount the Pynq rootfs on the directory you just created.
Note that the offset to the ext4 Linux partition (105906176 byte in this case) is obtained from the partition list above.
```
$ sudo mount --options loop,offset=105906176 bionic.arm.2.6.0_2020_10_19.img /mnt/pynq_image
```

Make sure that the Pynq rootfs is successfully mounted:
```
$ ls -l /mnt/pynq_image/
total 88
drwxr-xr-x   2 root root  4096 Oct 19  2020 bin
drwxr-xr-x   2 root root  4096 Oct 19  2020 boot
drwxr-xr-x   2 root root  4096 Oct 19  2020 dev
drwxr-xr-x 101 root root  4096 Oct 20  2020 etc
drwxr-xr-x   3 root root  4096 Oct 19  2020 home
drwxr-xr-x  13 root root  4096 Oct 19  2020 lib
lrwxrwxrwx   1 root root     5 Oct 19  2020 lib64 -> ./lib
drwx------   2 root root 16384 Oct 19  2020 lost+found
drwxr-xr-x   2 root root  4096 Oct 19  2020 media
drwxr-xr-x   2 root root  4096 Oct 19  2020 mnt
drwxr-xr-x   4 root root  4096 Oct 20  2020 opt
drwxr-xr-x   2 root root  4096 Apr 24  2018 proc
drwx------   7 root root  4096 Oct 20  2020 root
drwxr-xr-x   8 root root  4096 Oct 19  2020 run
drwxr-xr-x   2 root root  4096 Feb  6  2018 sbin
drwxr-xr-x   2 root root  4096 Oct 19  2020 srv
drwxr-xr-x   2 root root  4096 Apr 24  2018 sys
drwxrwxrwt  10 root root  4096 Oct 20  2020 tmp
drwxr-xr-x  10 root root  4096 Oct 19  2020 usr
drwxr-xr-x  12 root root  4096 Oct 19  2020 var
```

Compress the entire Pynq rootfs (all files under the mount point `/mnt/pynq_image`) and create a `tar.gz` archive (`bionic.arm.2.6.0_2020_10_19.tar.gz` in the following example):
```
$ sudo tar cvfz bionic.arm.2.6.0_2020_10_19.tar.gz -C /mnt/pynq_image .

$ ls -lh bionic.arm.2.6.0_2020_10_19.tar.gz 
-rw-rw-r-- 1 stern stern 1.6G May 15 22:31 bionic.arm.2.6.0_2020_10_19.tar.gz

$ tar tfv bionic.arm.2.6.0_2020_10_19.tar.gz | grep -i "./usr/bin" | head
drwxr-xr-x root/root          0 2020-10-20 03:02 ./usr/bin/
-rwxr-xr-x root/root    4009204 2018-04-25 00:47 ./usr/bin/ctest
-rwxr-sr-x root/utmp       5540 2017-01-30 03:02 ./usr/bin/Eterm
-rwxr-xr-x root/root      40276 2016-05-31 10:27 ./usr/bin/ico
-rwxr-xr-x root/root       1282 2017-08-04 23:19 ./usr/bin/libftdi-config
lrwxrwxrwx root/root          0 2018-04-10 18:48 ./usr/bin/python3 -> python3.6
-rwxr-xr-x root/root      29112 2018-03-30 17:01 ./usr/bin/dh
-rwxr-xr-x root/root       2841 2018-03-30 17:01 ./usr/bin/dh_auto_install
-rwxr-xr-x root/root       6273 2018-03-30 17:01 ./usr/bin/dh_shlibdeps
lrwxrwxrwx root/root          0 2018-04-21 01:55 ./usr/bin/systemd-umount -> systemd-mount
```

## Importing and testing the image file for Docker

Import the `tar.gz` archive as the Docker image file (I just set the `pynq-image` as the repository and `v2.6-2021-05-15` as the tag):
```
$ sudo docker image import bionic.arm.2.6.0_2020_10_19.tar.gz pynq-image:v2.6-2021-05-15
sha256:4b78910073fa13ae1b73801d8185f968af3a9cb0267aa9e5f114e7a19da62447

$ sudo docker image ls pynq-image
REPOSITORY   TAG               IMAGE ID       CREATED          SIZE
pynq-image   v2.6-2021-05-15   4b78910073fa   17 seconds ago   4.15GB
```

The Docker image above is for 32-bit armv7l architecture, but I am going to create and run containers on the x86\_64 host machine.
Therefore, I need to install the emulator (qemu) using `apt`:
```
$ sudo apt install qemu-user-static
$ qemu-arm-static --version
qemu-arm version 4.2.1 (Debian 1:4.2-3ubuntu6.18)
Copyright (c) 2003-2019 Fabrice Bellard and the QEMU Project developers
```

Create a directory to share the wheel files between the x86\_64 host machine and Docker containers (`data` in this example).
I am going to build wheel files inside Pynq Docker containers and retrieve them from this directory.
```
$ mkdir data
```

Create a new container for testing (`pynq-test` in the following example).
We mount the directory above to share the wheel files (`$(pwd)/data:/data`) and also the emulator (`/usr/bin/qemu-arm-static`) to run armv7l containers on the x86\_64 host machine.
```
$ sudo docker container run -it --name pynq-test \
 --volume /usr/bin/qemu-arm-static:/usr/bin/qemu-arm-static \
 --volume $(pwd)/data:/data pynq-image:v2.6-2021-05-15 /bin/bash
root@dec5fb7f5b41:/#
```

`arch` command returns the correct architecture (armv7l).
However, we see the information of the host machine (Intel Xeon E5-1620, 128GB RAM in this example) by reading the virtual files `/proc/cpuinfo` and `/proc/meminfo` in the container, so we have to be careful about it when building PyTorch from source.
```
root@dec5fb7f5b41:/# arch
armv7l

root@dec5fb7f5b41:~# cat /proc/cpuinfo | grep "model name" | uniq
model name	: Intel(R) Xeon(R) CPU E5-1620 v2 @ 3.70GHz

root@dec5fb7f5b41:/# cat /proc/meminfo | head
MemTotal:       131872232 kB
MemFree:        86231936 kB
MemAvailable:   127111280 kB
Buffers:         1363252 kB
Cached:         38035864 kB
SwapCached:            0 kB
Active:         12017468 kB
Inactive:       30522020 kB
Active(anon):    3141876 kB
Inactive(anon):      688 kB
```

We can detach from container by pressing the escape sequence (`Ctrl-p` and `Ctrl-q`) and leave it running in background.
We see that the container is still running:
```
$ sudo docker ps -a
CONTAINER ID   IMAGE                        COMMAND       CREATED          STATUS
PORTS     NAMES
dec5fb7f5b41   pynq-image:v2.6-2021-05-15   "/bin/bash"   2 minutes ago    Up About a minute             pynq-test
```

We can attach to the running container:
```
$ sudo docker attach pynq-test
root@dec5fb7f5b41:/#
```

Let's create some file inside the container and put it on the shared directory:
```
root@dec5fb7f5b41:/data# echo "Hello, World!" > test.txt
root@dec5fb7f5b41:/data# ls
test.txt
```

We can see the file created inside the container from the host machine:
```
$ cd data
$ cat test.txt
Hello, World!
```

## Building PyTorch wheel in the container

I am going to build PyTorch 1.9.1 from source in this example.

First, clone the [PyTorch GitHub repository](https://github.com/pytorch/pytorch) and place it somewhere inside the container (`$HOME/pytorch-1.9.1` or `/root/pytorch-1.9.1` in this example), which takes some time:
```
root@dec5fb7f5b41:~# git clone https://github.com/pytorch/pytorch pytorch-1.9.1
Cloning into 'pytorch-1.9.1'...
remote: Enumerating objects: 700563, done.
remote: Counting objects: 100% (370/370), done.
remote: Compressing objects: 100% (238/238), done.
remote: Total 700563 (delta 308), reused 163 (delta 132), pack-reused 700193
Receiving objects: 100% (700563/700563), 660.94 MiB | 6.22 MiB/s, done.
Resolving deltas: 100% (568153/568153), done.
Checking out files: 100% (9482/9482), done.
```

Then, checkout the version you want to use (`v1.9.1` in this example).
Do not forget to synchronize and update submodules (you can use `git submodule sync` and `git submodule update --init --recursive`).
```
root@dec5fb7f5b41:~# cd pytorch-1.9.1/
root@dec5fb7f5b41:~/pytorch-1.9.1#

root@dec5fb7f5b41:~/pytorch-1.9.1# git tag
...v1.8.0
v1.8.0-rc1
v1.8.0-rc2
v1.8.0-rc3
v1.8.0-rc4
v1.8.0-rc5
v1.8.1
v1.8.1-rc1
v1.8.1-rc2
v1.8.1-rc3
v1.8.2
v1.8.2-rc1
v1.9.0
v1.9.0-rc1
v1.9.0-rc2
v1.9.0-rc3
v1.9.0-rc4
v1.9.1
v1.9.1-rc1
v1.9.1-rc2

root@dec5fb7f5b41:~/pytorch-1.9.1# git checkout refs/tags/v1.9.1
Checking out files: 100% (5497/5497), done.
Note: checking out 'refs/tags/v1.9.1'.

You are in 'detached HEAD' state. You can look around, make experimental
changes and commit them, and you can discard any commits you make in this
state without impacting any branches by performing another checkout.

If you want to create a new branch to retain commits you create, you may
do so (now or later) by using -b with the checkout command again. Example:

  git checkout -b <new-branch-name>

HEAD is now at dfbd030854 Fix builder pinning (#64971)

root@dec5fb7f5b41:~/pytorch-1.9.1# git status
HEAD detached at v1.9.1
nothing to commit, working tree clean

root@dec5fb7f5b41:~/pytorch-1.9.1# git submodule sync

root@dec5fb7f5b41:~/pytorch-1.9.1# git submodule update --init --recursive
Submodule 'android/libs/fbjni' (https://github.com/facebookincubator/fbjni.git) registered for path 'android/libs/fbjni'
Submodule 'third_party/NNPACK_deps/FP16' (https://github.com/Maratyszcza/FP16.git) registered for path 'third_party/FP16'
Submodule 'third_party/NNPACK_deps/FXdiv' (https://github.com/Maratyszcza/FXdiv.git) registered for path 'third_party/FXdiv'
Submodule 'third_party/NNPACK' (https://github.com/Maratyszcza/NNPACK.git) registered for path 'third_party/NNPACK'
Submodule 'third_party/QNNPACK' (https://github.com/pytorch/QNNPACK) registered for path 'third_party/QNNPACK'
Submodule 'third_party/XNNPACK' (https://github.com/google/XNNPACK.git) registered for path 'third_party/XNNPACK'
...
Cloning into '/root/pytorch-1.9.1/third_party/tensorpipe/third_party/pybind11/tools/clang'...
Submodule path 'third_party/tensorpipe/third_party/pybind11/tools/clang': checked out '6a00cbc4a9b8e68b71caf7f774b3f9c753ae84d5'
Submodule path 'third_party/zstd': checked out 'aec56a52fbab207fc639a1937d1e708a282edca8'
```

We need several Python packages like `future`, `numpy`, `setuptools`, `typing_extensions`, and `dataclasses` to build PyTorch from source.
Install these dependencies using `requirements.txt`:
```
root@dec5fb7f5b41:~/pytorch-1.9.1# ls
BUILD.bazel         Dockerfile   README.md    aten.bzl    codecov.yml      mypy-strict.ini          scripts      torch
CITATION            GLOSSARY.md  RELEASE.md   benchmarks  docker           mypy.ini                 setup.py     ubsan.supp
CMakeLists.txt      LICENSE      SECURITY.md  binaries    docker.Makefile  mypy_plugins             submodules   version.txt
CODEOWNERS          MANIFEST.in  WORKSPACE    c10         docs             pytest.ini               test
CODE_OF_CONDUCT.md  Makefile     android      caffe2      ios              requirements-flake8.txt  third_party
CONTRIBUTING.md     NOTICE       aten         cmake       modules          requirements.txt         tools

root@dec5fb7f5b41:~/pytorch-1.9.1# cat requirements.txt
# Python dependencies required for development
astunparse
expecttest
future
numpy
psutil
pyyaml
requests
setuptools
six
types-dataclasses
typing_extensions
dataclasses; python_version<"3.7"

root@dec5fb7f5b41:~/pytorch-1.9.1# pip3 install -r requirements.txt 
Collecting astunparse
  Downloading astunparse-1.6.3-py2.py3-none-any.whl (12 kB)
Collecting expecttest
  Downloading expecttest-0.1.3-py3-none-any.whl (6.5 kB)
Collecting future
  Downloading future-0.18.2.tar.gz (829 kB)
     |################################| 829 kB 2.8 MB/s 
Requirement already satisfied: numpy in /usr/local/lib/python3.6/dist-packages (from -r requirements.txt (line 5)) (1.16.0)
Requirement already satisfied: psutil in /usr/local/lib/python3.6/dist-packages (from -r requirements.txt (line 6)) (5.7.0)
Requirement already satisfied: pyyaml in /usr/lib/python3/dist-packages (from -r requirements.txt (line 7)) (3.12)
Requirement already satisfied: requests in /usr/lib/python3/dist-packages (from -r requirements.txt (line 8)) (2.18.4)
Requirement already satisfied: setuptools in /usr/lib/python3/dist-packages (from -r requirements.txt (line 9)) (39.0.1)
Requirement already satisfied: six in /usr/lib/python3/dist-packages (from -r requirements.txt (line 10)) (1.11.0)
Collecting types-dataclasses
  Downloading types_dataclasses-0.6.1-py3-none-any.whl (2.7 kB)
Collecting typing_extensions
  Downloading typing_extensions-3.10.0.2-py3-none-any.whl (26 kB)
Collecting dataclasses
  Downloading dataclasses-0.8-py3-none-any.whl (19 kB)
Requirement already satisfied: wheel<1.0,>=0.23.0 in /usr/lib/python3/dist-packages (from astunparse->-r requirements.txt (line 2)) (0.30.0)
Building wheels for collected packages: future
  Building wheel for future (setup.py) ... done
  Created wheel for future: filename=future-0.18.2-py3-none-any.whl size=493275 sha256=5826ef3ad17848253fb87d9c05a1d1ebf81000877d63036772e134be8a5acc2a
  Stored in directory: /root/.cache/pip/wheels/6e/9c/ed/4499c9865ac1002697793e0ae05ba6be33553d098f3347fb94
Successfully built future
Installing collected packages: astunparse, expecttest, future, types-dataclasses, typing-extensions, dataclasses
Successfully installed astunparse-1.6.3 dataclasses-0.8 expecttest-0.1.3 future-0.18.2 types-dataclasses-0.6.1 typing-extensions-3.10.0.2
WARNING: You are using pip version 20.2.4; however, version 21.3.1 is available.
You should consider upgrading via the '/usr/bin/python3.6 -m pip install --upgrade pip' command.
```

We need to set some environment variables before building PyTorch.
Relevant environment variables are listed in the `setup.py`.
```
root@dec5fb7f5b41:~/pytorch-1.9.1# cat setup.py | head -n 70
# Welcome to the PyTorch setup.py.
#
# Environment variables you are probably interested in:
#
#   DEBUG
#     build with -O0 and -g (debug symbols)
#
#   REL_WITH_DEB_INFO
#     build with optimizations and -g (debug symbols)
#
#   MAX_JOBS
#     maximum number of compile jobs we should use to compile your code
#
#   USE_CUDA=0
#     disables CUDA build
#
#   CFLAGS
#     flags to apply to both C and C++ files to be compiled (a quirk of setup.py
#     which we have faithfully adhered to in our build system is that CFLAGS
#     also applies to C++ files (unless CXXFLAGS is set), in contrast to the
#     default behavior of autogoo and cmake build systems.)
#
#   CC
#     the C/C++ compiler to use
#
# Environment variables for feature toggles:
#
#   USE_CUDNN=0
#     disables the cuDNN build
#
#   USE_FBGEMM=0
#     disables the FBGEMM build
#
#   USE_KINETO=0
#     disables usage of libkineto library for profiling
#
#   USE_NUMPY=0
#     disables the NumPy build
#
#   BUILD_TEST=0
#     disables the test build
#
#   USE_MKLDNN=0
#     disables use of MKLDNN
#
#   USE_MKLDNN_ACL
#     enables use of Compute Library backend for MKLDNN on Arm;
#     USE_MKLDNN must be explicitly enabled.
#
#   MKLDNN_CPU_RUNTIME
#     MKL-DNN threading mode: TBB or OMP (default)
#
#   USE_NNPACK=0
#     disables NNPACK build
#
#   USE_QNNPACK=0
#     disables QNNPACK build (quantized 8-bit operators)
#
#   USE_DISTRIBUTED=0
#     disables distributed (c10d, gloo, mpi, etc.) build
#
#   USE_TENSORPIPE=0
#     disables distributed Tensorpipe backend build
#
#   USE_GLOO=0
#     disables distributed gloo backend build
#
#   USE_MPI=0
#     disables distributed MPI backend build
#
```

- Set `CFLAGS="-mfpu=neon -D__NEON__"` to enable ARM Neon intrinsics.
CMake module `cmake/Modules/FindARM.cmake` checks whether the Neon instruction is available or not on the machine by reading `/proc/cpuinfo`, and another CMake module `cmake/Dependencies.cmake` appends the compiler options to use Neon intrinsics (`-mfpu=neon -D__NEON__`).
In the Docker container, however, `/proc/cpuinfo` prints the CPU information of the host machine (Intel Xeon E5-1620 in this case), and Neon intrinsics is not detected.
For workaround, we manually append the compiler options (`-mfpu=neon -D__NEON__`) to use Neon intrinsics.
If you are building wheels for ZCU-104 (aarch64), set `CFLAGS="-D__NEON__"` instead of `CFLAGS="-mfpu=neon -D__NEON__"`.
- Set `USE_CUDA=0` and `USE_CUDNN=0` to disable CUDA and cuDNN builds, because these are not available on the Pynq-Z2 and ZCU-104.
- Set `BUILD_TEST=0` to disable the test build and reduce the compile time.
- Set `USE_MKLDNN=0` to disable use of MKLDNN (Intel Math Kernel Library for Deep Neural Networks), because we are going to build for ARM Cortex CPUs.
- Set `USE_DISTRIBUTED=0` to disable distributed build, simply because we are not going to use it.
```
root@dec5fb7f5b41:~/pytorch-1.9.1# export CFLAGS="-mfpu=neon -D__NEON__"
root@dec5fb7f5b41:~/pytorch-1.9.1# export USE_CUDA=0
root@dec5fb7f5b41:~/pytorch-1.9.1# export USE_CUDNN=0
root@dec5fb7f5b41:~/pytorch-1.9.1# export BUILD_TEST=0
root@dec5fb7f5b41:~/pytorch-1.9.1# export USE_MKLDNN=0
root@dec5fb7f5b41:~/pytorch-1.9.1# export USE_DISTRIBUTED=0
```

We could create some Bash scripts to set the environment variables like this:
```
root@dec5fb7f5b41:~/pytorch-1.9.1# cat pytorch-1.9.1-set-env.sh
#!/bin/bash
# pytorch-1.9.1-set-env.sh

# Use the following command to set environment variables for building PyTorch:
# $ . pytorch-1.9.1-set-env.sh
# Do not use the following command:
# $ pytorch-1.9.1-set-env.sh

export CFLAGS="-mfpu=neon -D__NEON__"
export USE_CUDA=0
export USE_CUDNN=0
export BUILD_TEST=0
export USE_MKLDNN=0
export USE_DISTRIBUTED=0

root@dec5fb7f5b41:~/pytorch-1.9.1# chmod a+x pytorch-1.9.1-set-env.sh

root@dec5fb7f5b41:~/pytorch-1.9.1# . pytorch-1.9.1-set-env.sh

root@dec5fb7f5b41:~/pytorch-1.9.1# echo $CFLAGS
-mfpu=neon -D__NEON__
```

Install Ninja build tool using `apt` to perform a parallel build:
```
root@dec5fb7f5b41:~/pytorch-1.9.1# sudo apt update
Get:1 http://ports.ubuntu.com/ubuntu-ports bionic InRelease [242 kB]
Get:2 http://ports.ubuntu.com/ubuntu-ports bionic/main Sources [829 kB]
Get:3 http://ports.ubuntu.com/ubuntu-ports bionic/universe Sources [9,051 kB]
Get:4 http://ports.ubuntu.com/ubuntu-ports bionic/main armhf Packages [968 kB]
Get:5 http://ports.ubuntu.com/ubuntu-ports bionic/main Translation-en [516 kB]
Get:6 http://ports.ubuntu.com/ubuntu-ports bionic/universe armhf Packages [8,269 kB]
Get:7 http://ports.ubuntu.com/ubuntu-ports bionic/universe Translation-en [4,941 kB]
Fetched 24.8 MB in 27s (914 kB/s)
Reading package lists... Done
Building dependency tree... Done
378 packages can be upgraded. Run 'apt list --upgradable' to see them.

root@dec5fb7f5b41:~/pytorch-1.9.1# sudo apt install ninja-build
Reading package lists... Done
Building dependency tree... Done
The following NEW packages will be installed:
  ninja-build
0 upgraded, 1 newly installed, 0 to remove and 378 not upgraded.
Need to get 82.6 kB of archives.
After this operation, 217 kB of additional disk space will be used.
Get:1 http://ports.ubuntu.com/ubuntu-ports bionic/universe armhf ninja-build armhf 1.8.2-1 [82.6 kB]
Fetched 82.6 kB in 1s (80.2 kB/s)
Selecting previously unselected package ninja-build.
(Reading database ... 122054 files and directories currently installed.)
Preparing to unpack .../ninja-build_1.8.2-1_armhf.deb ...
Unpacking ninja-build (1.8.2-1) ...
Processing triggers for man-db (2.8.3-2) ...
Setting up ninja-build (1.8.2-1) ...

root@dec5fb7f5b41:~/pytorch-1.9.1# which ninja
/usr/bin/ninja
```

After Ninja is successfully installed, build the PyTorch using `setup.py`, which may take several hours.
We should double-check that ARM Neon instruction is enabled (`-mfpu=neon -D__NEON__`).
We recommend using `tmux` or `screen` if you are using the host machine over SSH.
```
root@dec5fb7f5b41:~/pytorch-1.9.1# python3 setup.py build
Building wheel torch-1.9.0a0+gitdfbd030
-- Building version 1.9.0a0+gitdfbd030
cmake -GNinja -DBUILD_PYTHON=True -DBUILD_TEST=False -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/root/pytorch-1.9.1/torch -DCMAKE_PREFIX_PATH=/usr/lib/python3.6/site-packages -DNUMPY_INCLUDE_DIR=/usr/local/lib/python3.6/dist-packages/numpy/core/include -DPYTHON_EXECUTABLE=/usr/bin/python3 -DPYTHON_INCLUDE_DIR=/usr/include/python3.6m -DPYTHON_LIBRARY=/usr/lib/libpython3.6m.so.1.0 -DTORCH_BUILD_VERSION=1.9.0a0+gitdfbd030 -DUSE_CUDA=0 -DUSE_CUDNN=0 -DUSE_DISTRIBUTED=0 -DUSE_MKLDNN=0 -DUSE_NUMPY=True /root/pytorch-1.9.1
-- The CXX compiler identification is GNU 7.3.0
-- The C compiler identification is GNU 7.3.0
-- Check for working CXX compiler: /usr/bin/c++
-- Check for working CXX compiler: /usr/bin/c++ -- works
...

******** Summary ********
-- General:
--   CMake version         : 3.10.2
--   CMake command         : /usr/bin/cmake
--   System                : Linux
--   C++ compiler          : /usr/bin/c++
--   C++ compiler id       : GNU
--   C++ compiler version  : 7.3.0
--   Using ccache if found : ON
--   Found ccache          : /usr/bin/ccache
--   CXX flags             : -mfpu=neon -D__NEON__ -fvisibility-inlines-hidden -DUSE_PTHREADPOOL -fopenmp -DNDEBUG -DUSE_KINETO -DLIBKINETO_NOCUPTI -DUSE_QNNPACK -DUSE_PYTORCH_QNNPACK -DUSE_XNNPACK -DSYMBOLICATE_MOBILE_DEBUG_HANDLE -O2 -fPIC -Wno-narrowing -Wall -Wextra -Werror=return-type -Wno-missing-field-initializers -Wno-type-limits -Wno-array-bounds -Wno-unknown-pragmas -Wno-sign-compare -Wno-unused-parameter -Wno-unused-variable -Wno-unused-function -Wno-unused-result -Wno-unused-local-typedefs -Wno-strict-overflow -Wno-strict-aliasing -Wno-error=deprecated-declarations -Wno-stringop-overflow -Wno-psabi -Wno-error=pedantic -Wno-error=redundant-decls -Wno-error=old-style-cast -fdiagnostics-color=always -faligned-new -Wno-unused-but-set-variable -Wno-maybe-uninitialized -fno-math-errno -fno-trapping-math -Werror=format -Wno-stringop-overflow
--   Build type            : Release
--   Compile definitions   : ONNX_ML=1;ONNXIFI_ENABLE_EXT=1;ONNX_NAMESPACE=onnx_torch;HAVE_MMAP=1;_FILE_OFFSET_BITS=64;HAVE_SHM_OPEN=1;HAVE_SHM_UNLINK=1;HAVE_MALLOC_USABLE_SIZE=1;USE_EXTERNAL_MZCRC;MINIZ_DISABLE_ZIP_READER_CRC32_CHECKS
--   CMAKE_PREFIX_PATH     : /usr/lib/python3.6/site-packages
--   CMAKE_INSTALL_PREFIX  : /root/pytorch-1.9.1/torch
--   USE_GOLD_LINKER       : OFF
-- 
--   TORCH_VERSION         : 1.9.0
--   CAFFE2_VERSION        : 1.9.0
--   BUILD_CAFFE2          : ON
--   BUILD_CAFFE2_OPS      : ON
--   BUILD_CAFFE2_MOBILE   : OFF
--   BUILD_STATIC_RUNTIME_BENCHMARK: OFF
--   BUILD_TENSOREXPR_BENCHMARK: OFF
--   BUILD_BINARY          : OFF
--   BUILD_CUSTOM_PROTOBUF : ON
--     Link local protobuf : ON
--   BUILD_DOCS            : OFF
--   BUILD_PYTHON          : True
--     Python version      : 3.6.5
--     Python executable   : /usr/bin/python3
--     Pythonlibs version  : 3.6.5
--     Python library      : /usr/lib/libpython3.6m.so.1.0
--     Python includes     : /usr/include/python3.6m
--     Python site-packages: lib/python3.6/site-packages
--   BUILD_SHARED_LIBS     : ON
--   CAFFE2_USE_MSVC_STATIC_RUNTIME     : OFF
--   BUILD_TEST            : False
--   BUILD_JNI             : OFF
--   BUILD_MOBILE_AUTOGRAD : OFF
--   BUILD_LITE_INTERPRETER: OFF
--   INTERN_BUILD_MOBILE   : 
--   USE_BLAS              : 1
--     BLAS                : generic
--   USE_LAPACK            : 1
--     LAPACK              : generic
--   USE_ASAN              : OFF
--   USE_CPP_CODE_COVERAGE : OFF
--   USE_CUDA              : 0
--   USE_ROCM              : OFF
--   USE_EIGEN_FOR_BLAS    : ON
--   USE_FBGEMM            : OFF
--     USE_FAKELOWP          : OFF
--   USE_KINETO            : ON
--   USE_FFMPEG            : OFF
--   USE_GFLAGS            : OFF
--   USE_GLOG              : OFF
--   USE_LEVELDB           : OFF
--   USE_LITE_PROTO        : OFF
--   USE_LMDB              : OFF
--   USE_METAL             : OFF
--   USE_PYTORCH_METAL     : OFF
--   USE_FFTW              : OFF
--   USE_MKL               : OFF
--   USE_MKLDNN            : OFF
--   USE_NCCL              : OFF
--   USE_NNPACK            : ON
--   USE_NUMPY             : ON
--   USE_OBSERVERS         : ON
--   USE_OPENCL            : OFF
--   USE_OPENCV            : OFF
--   USE_OPENMP            : ON
--   USE_TBB               : OFF
--   USE_VULKAN            : OFF
--   USE_PROF              : OFF
--   USE_QNNPACK           : ON
--   USE_PYTORCH_QNNPACK   : ON
--   USE_REDIS             : OFF
--   USE_ROCKSDB           : OFF
--   USE_ZMQ               : OFF
--   USE_DISTRIBUTED       : 0
--   USE_DEPLOY           : OFF
--   Public Dependencies  : Threads::Threads
--   Private Dependencies : pthreadpool;cpuinfo;qnnpack;pytorch_qnnpack;nnpack;XNNPACK;fp16;aten_op_header_gen;foxi_loader;rt;fmt::fmt-header-only;kineto;gcc_s;gcc;dl
-- Configuring done
-- Generating done
-- Build files have been written to: /root/pytorch-1.9.1/build
cmake --build . --target install --config Release -- -j 8
[691/3616] Building C object sleef/src/libm/CMakeFiles/sleefdetpurec_scalar.dir/sleefsimddp.c.o
```

## Building TorchVision wheel in the container

