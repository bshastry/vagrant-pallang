#### Introduction

This is a vagrant box that demos *PALLang*---acronym for Program Analysis with LLVM and Clang---a heuristics based program analysis tool that eagerly flags uses of potentially undefined CXX fields in Chromium code. The original motivation was to complement MSan with an earlier stage static analysis.

The hope is that developers tolerate many more false positives than MSan while getting analysis diagnostics at an earlier stage of development. Having said that, with this tool, a serious effort is made to bring down the number of false positives by supplementing Clang SA runs with an LLVM pass that has global outlook. The idea is to filter out bug reports that are or are likely false positives so developers look at bugs that merit attention. In the LLVM pass, filtering is done by simple taint analysis on the LLVM libraries where bugs manifest. The biggest LLVM library that analysis is done on is libpdf.a which is 328 MB in size.

Since running Clang SA and/or LLVM pass on chromium code is expensive (read ~12 hours wall clock time for analyzing the pdf ninja project), Clang SA bug reports and results of LLVM pass against these reports have been preloaded in the box. You can use scan-view (available in the box) to look at Clang SA bug reports and a text editor to look at LLVM pass results. For Clang SA bug reports, on the scan view dashboard, the checker that is part of PALLang may be identified by the description `Undefined CXX object checker` under the `Logic Error` bug type. There are 159 bug reports flagged by the checker in the `pdf` ninja project i.e., while building libpdf.so in Chromium.

If you have enough compute power on the host, you can even exercise the LLVM pass over preloaded Clang SA reports afresh. For this, the box contains a bash wrapper (`BSparserCaller.sh`) around a python script (`BSparser.py`) that exercises the LLVM pass part of PALLang against Clang SA bug reports of libpdf.

Seeing preloaded bug reports is highly recommended as a good starting point. This gives you an impression of:

1. False positives weeded out by LLVM analysis.
2. More informative diagnostics on bugs that merit attention.

As a teaser, in the specific instance of pdf (ninja project) analysis, of the 159 reports flagged by checker, LLVM pass classifies ~70 as false positives. Of the remaining, it provides extended diagnostics for ~40 bug reports.

#### Demo: Provisioning and running

**Pre-requisites**

- vagrant (Tested on v1.7.2)
- virtualbox (Tested on v4.3.14)

For exercising LLVM pass in the box, you'll need

- VT-x enabled on host
- Sufficient RAM [4G RAM allocated to guest]
- lscpu shows at least 2 CPUs

*Note*

If you don't intend to run the pass in the guest, it is safe to comment out the following portions of Vagrantfile. Besides, if your host architecture does not support VT-x and/or you don't have much compute power to spare, this is a must.

```txt
#  config.vm.provider "virtualbox" do |v|
#        v.name = "pallang-vm"
#        v.customize ["modifyvm", :id, "--cpuexecutioncap", "90"]
#        v.memory = 4096
#        v.cpus = 2
#  end
```
 
**Command line**

*Clone box config*

```bash
cd $YOUR_WORK_DIR
git clone git@gitlab.sec.t-labs.tu-berlin.de:static-analysis/vagrant-pallang.git
cd vagrant-pallang
```

At this point, you would need to generate a keypair and place them in the conf.d directory. This is going to be the deploy key for your box instance. The provisioning script (`provision.sh`) copies the generated private key to the box's `$HOME/.ssh`. Once you have generated a keypair, please file an issue on gitlab so we can add the public key on the server side. After your public key has been added, you will be notified by email. You can then fetch the demo tarball. Do:

*Bring up box and fetch demo tarball*

```bash
vagrant up
## This gives you an ssh shell in the box with X forwarding enabled
vagrant ssh
## Fetches demo code. Might take a while. Roughly 550M of data over the network.
/vagrant/scripts/fetch.sh
```

This will fetch the demo code into $HOME/demo of the vagrant box.

*Simply view preloaded bug reports*

For viewing Clang SA bug reports, do:

```bash
scan-view $HOME/demo/scan-build-out/pdf
```

Firefox browser GUI instance on guest is forwarded to host. On the bug dashboard uncheck all and check only `CXX Undef Object Checker` to narrow attention to this tool.

For viewing LLVM pass results, do:

```bash
## Full report
vim $HOME/demo/pallang/preloaded/pass-vagrant-v1.6.1-pdf.txt

## Summary
vim $HOME/demo/pallang/preloaded/Summary.txt
```

*Running LLVM pass*

```bash
cd $HOME/demo/pallang
./BSparserCaller.sh &
```

This should print out results of LLVM pass to `$HOME/demo/pallang/passname.txt`. The script logs summary of the complete run (`Summary.txt`) and times each run of the pass against a bug report (`time-pass.txt`). What the script (`BSparserCaller.sh`) is doing is running the LLVM pass against a bunch of (159) Clang SA bug reports that were flagged by the heurisitcal checker. Please note that LLVM analysis can be I/O and CPU intensive. Some bug reports in libpdf require ~2 hours for analysis.

#### Miscellaneous

**Box contents**

- precise64 box
  - vim, git, clang-3.6, llvm-3.6, gcc-4.8, firefox installed
  - analysis infra
    - prebuilt llvm opt binary
    - Clang SA bug reports for pdf ninja
    - llvm-pass and pallang

Analysis infra is fetched by a script once deploy key has been set up.

**False positives**

This is WIP. Known sources of false positives of PALLang are:

- Array assignments e.g., int x[2]; x = y; x[0] = 0;
- Init/Create methods e.g., Foo fooObject; fooObject.init()
