#!/bin/bash

echo I am provisioning...

### Pre-reqs: GCC-4.8 for chromium, cmake as project builder
echo -e "Installing GCC-4.8, vim, llvm, clang and git"
sudo apt-get install -y python-software-properties &> /dev/null
sudo apt-add-repository -y ppa:ubuntu-toolchain-r/test &> /dev/null
sudo apt-get update &> /dev/null
sudo apt-get install -y gcc-4.8 &> /dev/null
sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.8 50

sudo apt-get install -y vim &> /dev/null
sudo apt-get install -y git &> /dev/null

sudo apt-get install -y clang &> /dev/null
sudo apt-get install -y llvm &> /dev/null

mkdir -p $HOME/depot_tools
cd $HOME/depot_tools

echo -e "Installing ninja from Chromium depot_tools"
git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git &> /dev/null

echo -e "Installing ssh key pair"
cp $1 /home/vagrant/.ssh/id_dsa

echo -e "Provisioning done"
