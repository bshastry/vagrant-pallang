#!/bin/bash

# Fetch prebuilt stuff and demo material
if [ ! -e prebuilt ]; then
wget --no-check-certificate -O tmp.tar.gz 'https://owncloud.sec.t-labs.tu-berlin.de/owncloud/public.php?service=files&t=9b2aedeb600d7d9a16ff442a9ee93b88&download'
tar -zxvf tmp.tar.gz
rm tmp.tar.gz
fi

# Fetch LLVM pass code
if [ ! -e llvm-pass ]; then
git clone git@gitlab.sec.t-labs.tu-berlin.de:static-analysis/llvm-pass.git
fi

# Fetch Pallang
if [ ! -e pallang ]; then
git clone git@gitlab.sec.t-labs.tu-berlin.de:static-analysis/pallang.git
fi
