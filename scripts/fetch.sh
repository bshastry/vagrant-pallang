#!/bin/bash

PATCHFILE="/vagrant/scripts/LLVMConfig.patch"
BUGGYFILE="/usr/share/llvm-3.6/cmake/LLVMConfig.cmake"

sudo patch -p1 --dry-run --silent $BUGGYFILE < $PATCHFILE 2>/dev/null

if [ $? -eq 0 ];
then
echo -e "\t[+] Patching LLVMConfig.cmake"
sudo patch -sp1 $BUGGYFILE < $PATCHFILE
fi

cd $HOME

command -v cmake >/dev/null 2>&1 || { echo -e "\t[+] Installing Cmake"; wget -q http://www.cmake.org/files/v3.1/cmake-3.1.3-Linux-x86_64.tar.gz; sudo tar --strip-components=1 -xzf cmake-3.1.3-Linux-x86_64.tar.gz -C /usr/local; rm cmake-3.1.3-Linux-x86_64.tar.gz; }

if [ ! -e depot_tools ]; then
echo -e "\t[+] Installing depot tools"
git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git &> /dev/null
sudo update-alternatives --install /usr/bin/ninja ninja /home/vagrant/depot_tools/ninja 50 &> /dev/null
sudo update-alternatives --install /usr/bin/ninja-linux64 ninja-linux64 /home/vagrant/depot_tools/ninja-linux64 50 &> /dev/null
fi

if [ -e demo ]; then
exit
fi

mkdir -p demo
cd demo

FETCH_FROM='https://owncloud.sec.t-labs.tu-berlin.de/owncloud/public.php?service=files&t=1b7c9e6f20d4cda3e45d18e9bbd1ec6a&download'

# Fetch prebuilt stuff and demo material
echo -e "\t[+] Fetching demo stuff. This is going to take a while..."
wget --no-check-certificate -qO demo.tar.gz $FETCH_FROM
echo -e "\t[+] Extracting demo tarball"
tar -zxf demo.tar.gz
rm demo.tar.gz

# Patch opt
echo -e "\t[+] Installing pre-built opt 3.7 debug build"
sudo update-alternatives --install /usr/bin/opt opt /home/vagrant/demo/prebuilt/clang-llvm/bin/opt 50 &> /dev/null

echo -e "\t[+] Adding gitlab public key to known hosts"
HOST="gitlab.sec.t-labs.tu-berlin.de"
touch ~/.ssh/known_hosts
ssh-keyscan -t rsa,dsa $HOST 2>&1 | sort -u - ~/.ssh/known_hosts > ~/.ssh/tmp_hosts
cat ~/.ssh/tmp_hosts >> ~/.ssh/known_hosts

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
