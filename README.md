### Introduction

This is a vagrant box that demos *PALLang*---acronym for Program Analysis with LLVM and Clang---a heuristics based program analysis tool that eagerly flags uses of potentially undefined CXX class members in source code. It is vaguely like lint, very vaguely if you look into it closely. Try it!

### Demo: Provisioning and running

#### Pre-requisites

On Host:

- [vagrant][1] (Tested with v1.7.2)
- virtualbox (Tested with v4.3.14)
- C++ codebase to analyze, preferably something you are familiar with

For running stage 2 analysis in the box, you'll need

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
 
#### Command line

**Clone box config**

```bash
user@host:~$ git clone git@gitlab.sec.t-labs.tu-berlin.de:static-analysis/vagrant-pallang.git
user@host:~$ cd vagrant-pallang
```

Next, bring up the box.

**Bring up box and fetch demo tarball**

```bash
user@host:<Vagrant-pallang-dir>$ vagrant up
## This gives you an ssh shell in the box with X11 forwarding
user@host:<Vagrant-pallang-dir>$ vagrant ssh
## Fetches demo code. Might take a while. Roughly 350M of data over the network.
vagrant@precise64:~$ /vagrant/scripts/fetch.sh
```

This will fetch the demo code into $HOME/demo of the vagrant box. At this point, the box is ready for analyzing code.
The analysis is performed over two stages. In stage 1, source code analysis is performed alongside compilation. In stage 2, IR code is analyzed. More on this later.

**Run Stage 1 analysis**

First, clone a c++ repo of your choice.

```bash
## Clone something
vagrant@precise64:~$ mkdir code; cd code
vagrant@precise64:~/code$ git clone $something

## Configure or something like that
vagrant@precise64:~/code/something$ pscan-build ./configure

## Make or something like that
vagrant@precise64:~/code/something$ pscan-build make
```

Note that analysis+compilation is possibly an order of magnitude slower than native compilation only. Expect high latency for large codebases. If you want this to be less intrusive on host processes, lower the max cpu execution cap in `Vagrantfile`, like so:

```bash
#        v.customize ["modifyvm", :id, "--cpuexecutioncap", "20"]
```

In addition, use `screen`/`tmux` to manage analysis sessions in the box. This way, you can leave box while analysis happens, peeking into the box at your leisure via `vagrant ssh` from the root vagrant directory.

Output of analysis i.e., Clang SA bug reports will be placed in `./scan-build-out` relative to $something directory. If you want stuff to persist on host PC after powering off vagrant box (via `vagrant halt` or `vagrant destroy`), do everything relative to `/vagrant` since that directory is explicitly synced with namesake on host prior to box poweroff.

Once analysis is complete, you can view an indexed summary of analysis results via `scan-view`:

```bash
vagrant@precise64:~/code/something$ scan-view ./scan-build-out/$DIRNAME
```

Next, you are ready to run second and final analysis against IR code. But before that you need to extract IR code from a native executable or library.

**Run Stage 2 analysis**

First, please locate analysis target, and then run `extract-bc` against it, like so:

```bash
vagrant@precise64:~/code/$something/PATH_TO_TARGET$ extract-bc -v target
```

This creates an LLVM module from the native library/executable. For the magic behind this, consult [whole program llvm][2].
Next, we run the second and final stage analysis.


```bash
vagrant@precise64:~/code/$something$ mkdir pallang; cd pallang
vagrant@precise64:~/code/$something$ pallang $PATH_TO_SCAN_BUILD_REPORTS $PATH_TO_BC_TARGET --wpa &
```

The filename `pass.*.txt` is going to contain pass results for bug reports analyzed. A summary of analysis will be printed to a namesake file once stage 2 analysis is complete.

Please note that LLVM analysis can be I/O and CPU intensive. Analysis of bug reports against huge LLVM modules (hundreds of MBs) require ~2 hours for analysis.

#### Box contents

- precise64 box
  - vim, git, clang-3.6, llvm-3.6, gcc-4.8, make, firefox installed
  - analysis infra
    - prebuilt llvm and patched clang binaries
    - prebuilt analysis plug-in provisioned as a shared library
    - Source code for llvm-pass and pallang script

[1]: https://www.vagrantup.com/
[2]: https://github.com/travitch/whole-program-llvm

### Misc

[Archive](Archive)
