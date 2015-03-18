#!/bin/bash

echo I am provisioning...

### Pre-reqs: GCC-4.8 for chromium, cmake as project builder
echo -e "Installing gcc-4.8 backport, vim, llvm, clang (3.6) and git"
sudo apt-get install -y python-software-properties
sudo add-apt-repository -y ppa:ubuntu-toolchain-r/test &> /dev/null
sudo add-apt-repository -y "deb http://llvm.org/apt/precise/ llvm-toolchain-precise-3.6 main"
wget -O - http://llvm.org/apt/llvm-snapshot.gpg.key | sudo apt-key add -

sudo apt-get update &> /dev/null
sudo apt-get install -y gcc-4.8 g++-4.8 &> /dev/null
sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.8 50
sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-4.8 50

sudo apt-get install -y vim &> /dev/null
sudo apt-get install -y git &> /dev/null

sudo apt-get install -y clang-3.6 &> /dev/null
sudo apt-get install -y llvm-3.6 &> /dev/null

echo -e "Installing ssh key pair"
cp $1 /home/vagrant/.ssh/id_dsa

echo -e "Provisioning done"
