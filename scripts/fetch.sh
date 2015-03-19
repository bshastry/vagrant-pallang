#!/bin/bash

echo -e "\t[+] Patching LLVMConfig.cmake"
sudo patch -sp1 /usr/share/llvm-3.6/cmake/LLVMConfig.cmake < /vagrant/scripts/LLVMConfig.patch

cd $HOME

command -v cmake >/dev/null 2>&1 || { echo -e "\t[+] Installing Cmake"; wget -q http://www.cmake.org/files/v3.1/cmake-3.1.3-Linux-i386.tar.gz; sudo tar --strip-components=1 -xzf cmake-3.1.3-Linux-i386.tar.gz -C /usr/local; rm cmake-3.1.3-Linux-i386.tar.gz; }

if [ ! -e depot_tools ]; then
echo -e "\t[+] Installing depot tools"
git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git &> /dev/null
sudo update-alternatives --install /usr/bin/ninja ninja /home/vagrant/depot_tools/ninja 50 &> /dev/null
fi

if [ -e demo ]; then
exit
fi

mkdir -p demo
cd demo

FETCH_FROM='https://owncloud.sec.t-labs.tu-berlin.de/owncloud/public.php?service=files&t=c3ec1d58809e9be6d1a03bd5e545d484&download'

# Fetch prebuilt stuff and demo material
echo -e "\t[+] Fetching demo stuff. This is going to take a while..."
wget --no-check-certificate -qO demo.tar.gz $FETCH_FROM
echo -e "\t[+] Extracting demo tarball"
tar -zxf demo.tar.gz
rm demo.tar.gz

# Fetch LLVM pass code
if [ ! -e llvm-pass ]; then
echo -e "\t[+] Cloning llvm pass"
git clone git@gitlab.sec.t-labs.tu-berlin.de:static-analysis/llvm-pass.git
cd llvm-pass
git checkout vagrant
mkdir -p build
cd build
echo -e "\t[+] Running CMake on llvm-pass"
cmake -DCMAKE_BUILD_TYPE=Debug -G Ninja ../
cd ../../
fi

# Fetch Pallang
if [ ! -e pallang ]; then
echo -e "\t[+] Cloning pallang vagrant branch"
git clone git@gitlab.sec.t-labs.tu-berlin.de:static-analysis/pallang.git
cd pallang
git checkout vagrant
cd ..
fi

echo -e "\t[+] Successfully fetched demo package"
