#!/bin/bash

echo -e "Patching LLVMConfig.cmake"
sudo patch -p1 /usr/share/llvm-3.6/cmake/LLVMConfig.cmake < LLVMConfig.patch

cd $HOME

command -v cmake >/dev/null 2>&1 || { echo -e "Installing Cmake"; wget http://www.cmake.org/files/v3.1/cmake-3.1.3-Linux-i386.tar.gz; sudo tar --strip-components=1 -xzf cmake-3.1.3-Linux-i386.tar.gz -C /usr/local; rm cmake-3.1.3-Linux-i386.tar.gz; }

if [ ! -e depot_tools ]; then
echo -e "Installing depot tools"
git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git &> /dev/null
export PATH=$PATH:$HOME/depot_tools
fi

if [ -e demo ]; then
exit
fi

mkdir -p demo
cd demo

# Fetch prebuilt stuff and demo material
echo -e "Fetching demo stuff"
wget --no-check-certificate -O tmp.tar.gz 'https://owncloud.sec.t-labs.tu-berlin.de/owncloud/public.php?service=files&t=9b2aedeb600d7d9a16ff442a9ee93b88&download'
tar -zxf tmp.tar.gz
rm tmp.tar.gz

# Fetch LLVM pass code
if [ ! -e llvm-pass ]; then
echo -e "Cloning llvm pass"
git clone git@gitlab.sec.t-labs.tu-berlin.de:static-analysis/llvm-pass.git
git checkout vagrant
mkdir -p llvm-pass/build
cd llvm-pass/build
echo -e "Running CMake on llvm-pass"
cmake -DCMAKE_BUILD_TYPE=Debug -G Ninja ../
cd ../../
fi

# Fetch Pallang
if [ ! -e pallang ]; then
echo -e "Cloning pallang vagrant branch"
git clone git@gitlab.sec.t-labs.tu-berlin.de:static-analysis/pallang.git
git checkout vagrant
fi
