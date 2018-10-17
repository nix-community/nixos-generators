# Description
A simple collection of nixos image builders.
Just put your stuff into the config.nix and then call one of the image builders.

for example:
```
./generate.sh <options>

 Options:
 kvm virtualbox openstack kexec iso install-iso
```

it echoes the path to a iso image, which you then can flash onto an usb-stick or mount & boot in a virtual machine.

we currently have following generators:

format | script
--- | ---
iso | ./generate.sh iso
kexec | ./generate.sh kexec
openstack | ./generate.sh openstack
virtualbox | ./generate.sh virtualbox
kvm        | ./generate.sh kvm

we also have following runners:

platform | script
--- | ---
qemu-kvm | -
