#!/bin/bash

echo I am provisioning...

export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true
sudo apt-get update &> /dev/null

### Pre-reqs: GCC-4.8 for chromium, cmake as project builder
echo -e "Installing gcc-4.8 backport, clang, vim, and git"
echo -e "This might take a while...Coffee, perhaps?"
sudo apt-get install -y python-software-properties &> /dev/null
sudo apt-get install -y python-bs4 &> /dev/null
sudo add-apt-repository -y ppa:ubuntu-toolchain-r/test &> /dev/null
#sudo add-apt-repository -y "deb http://llvm.org/apt/precise/ llvm-toolchain-precise-3.6 main" \
#&> /dev/null
#wget -qO - http://llvm.org/apt/llvm-snapshot.gpg.key | sudo apt-key add - &> /dev/null

sudo apt-get update &> /dev/null
sudo apt-get install -y gcc-4.8 g++-4.8 &> /dev/null
sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.8 50 &> /dev/null
sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-4.8 50 &> /dev/null

sudo apt-get install -y vim &> /dev/null
sudo apt-get install -y git &> /dev/null

#sudo apt-get install -y clang-3.6 &> /dev/null
#sudo apt-get install -y llvm-3.6 &> /dev/null
#sudo update-alternatives --install /usr/bin/opt opt /usr/bin/opt-3.6 50 &> /dev/null
#sudo update-alternatives --install /usr/bin/scan-build scan-build /usr/bin/scan-build-3.6 50 &> /dev/null
#sudo update-alternatives --install /usr/bin/scan-view scan-view /usr/bin/scan-view-3.6 50 &> /dev/null
sudo apt-get install clang &> /dev/null

echo -e "Installing ssh key pair"
cp $1 /home/vagrant/.ssh/id_dsa
sudo chown vagrant:vagrant /home/vagrant/.ssh/id_dsa

echo -e "Provisioning done"
