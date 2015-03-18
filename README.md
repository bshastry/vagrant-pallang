**Vagrant configuration**

Consists of:

- precise32 box
  - vim, git, clang, llvm, gcc-4.8 installed
  - analysis infra
    - prebuilt clang binary plus checker
    - scan-build reports from checker against pdf ninja
    - llvm-pass and pallang

Analysis infra is fetched by a script post deploy key add.

**Deploy key**

Please copy deploy (private) key into `conf.d` folder and mail the public key to bshastry@sec.t-labs.tu-berlin.de
