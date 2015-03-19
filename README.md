#### Introduction

This is a demo vagrant box that consists of *PALLang*---acronym for Program Analysis with LLVM and Clang---a heuristics based program analysis tool that eagerly flags uses of potentially undefined CXX fields in Chromium code. The original hope was to complement what MSan does but statically, as against dynamically (MSan approach).

The hope is that developers tolerate more false positives than MSan while getting analysis diagnostics at an earlier stage of development.

#### Demo

**Pre-requisites**

- vagrant (Tested on v1.7.2)
- virtualbox (Tested on v4.3.14)
 
**Command line**

```bash
cd $YOUR_WORK_DIR
git clone git@gitlab.sec.t-labs.tu-berlin.de:static-analysis/vagrant-pallang.git
cd vagrant-pallang
vagrant up
## Workaround for a possible hostname resolution bug on first boot
vagrant reload --provision
## This gives you an ssh shell in the box
vagrant ssh
```

Once you have the box running, please file an issue requesting your deploy key to be added to the gitlab repo's ACL. Once your public key has been deployed, more command line to fetch demo code/scripts. Once you are done fetching, you can finally try out the demo.

```bash
vagrant ssh
## Fetches demo code. Might take a while. Roughly 550M of data over the network.
/vagrant/scripts/fetch.sh
```

This will fetch the demo code into $HOME/demo of the vagrant box.

You can then try out the demo, like so:

```bash
cd $HOME/demo/pallang
./BSparserCaller.sh &
```

What the script is doing is running an LLVM pass against a bunch of (159) Clang SA bug reports that were flagged by the heurisitcal checker.

**What's the demo about?**

Demo package consists of pre-loaded bunch of Clang SA bug reports that were created by the heuristical checker. By exercizing `BSparserCaller.sh` what one is doing is to run an LLVM pass against these bug reports to weed out possible false positives.

One can see the bug reports flagged by the checker in vbox gui, like so:

```bash
scan-view $HOME/demo/scan-build-out/pdf
```

scan-view starts a local web server that serves a bug dashboard.

#### Miscellaneous

**Box contents**

- precise32 box
  - vim, git, clang, llvm, gcc-4.8 installed
  - analysis infra
    - prebuilt clang binary plus checker
    - scan-build reports from checker against pdf ninja
    - llvm-pass and pallang

Analysis infra is fetched by a script post deploy key add.

*Deploy key*

Please copy deploy (private) key into `conf.d` folder and file an issue on this repo's issue tracker requesting your public key to be added as a deploy key.

**False positives**

Known sources of false positives of PALLang are:

- Array assignments e.g., int x[2]; x = y; x[0] = 0;
- Init/Create methods e.g., Foo fooObject; fooObject.init()

