# Description
A simple collection of nixos image builders.
Just put your stuff into the config.nix and then call one of the image builders.

for example:
```
./generate <mode> <options>

Mode:
    kvm virtualbox openstack kexec iso install-iso

Options:
    -c, --config
        Nix configuration file as absolute path. Default: ./config.nix
    -i, --image
        Absolut path to generate image to.
```

it echoes the path to a iso image, which you then can flash onto an usb-stick or mount & boot in a virtual machine.

we currently have following generators:

format | script
--- | ---
iso | ./generate iso
kexec | ./generate kexec
openstack | ./generate openstack
virtualbox | ./generate virtualbox
kvm        | ./generate kvm

we also have following runners:

platform | script
--- | ---
qemu-kvm | -
