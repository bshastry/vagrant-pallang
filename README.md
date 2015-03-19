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

**Command line**

```bash
cd vagrant-pallang
vagrant up
vagrant reload --provision
vagrant ssh
```

Please file an issue on gitlab for requesting your deploy key to be added to the gitlab repo's ACL. In the issue, please attach the public key.

Once your public key has been added, you will be notified by email or so. Then, please do:

```bash
vagrant ssh
/vagrant/scripts/fetch.sh
```

This will fetch the demo code into $HOME/demo of the vagrant box.

You can then try out the demo, like so

```bash
cd $HOME/demo/pallang
./BSparserCaller.sh &
```

