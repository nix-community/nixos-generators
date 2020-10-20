# nixos-generators - one config, multiple formats

The nixos-generators project allows to take the same NixOS configuration, and
generate outputs for different target formats.

Just put your stuff into the configuration.nix and then call one of the image builders.

for example:
```
nixos-generate -f iso
```
or

```
nixos-generate -f iso -c /etc/nixos/configuration.nix
```

it echoes the path to a iso image, which you then can flash onto an usb-stick
or mount & boot in a virtual machine.

# Installation

nixos-generators can be installed from source into the user profile like this:

```console
nix-env -f https://github.com/nix-community/nixos-generators/archive/master.tar.gz -i
```

## Supported formats

format | description
--- | ---
amazon | Amazon EC2 image
azure | Microsoft azure image (Generation 1 / VHD)
cloudstack | qcow2 image for cloudstack
do | Digital Ocean image
gce | Google Compute image
hyperv | Hyper-V Image (Generation 2 / VHDX)
install-iso | Installer ISO
install-iso-hyperv | Installer ISO with enabled hyper-v support
iso | ISO
kexec | kexec tarball (extract to / and run /kexec_nixos)
kexec-bundle | same as before, but it's just an executable
lxc | create a tarball which is importable as an lxc container, use together with lxc-metadata
lxc-metadata | the necessary metadata for the lxc image to start, usage: lxc image import $(nixos-generate -f lxc-metadata) $(nixos-generate -f lxc)
openstack | qcow2 image for openstack
qcow | qcow2 image
raw | raw image with bios/mbr
raw-efi | raw image with efi support
sd-aarch64 | Like sd-aarch64-installer, but does not use default installer image config.
sd-aarch64-installer | create an installer sd card for aarch64. For cross compiling use `--system aarch64-linux` and read the cross-compile section.
vagrant-virtualbox | VirtualBox image for [Vagrant](https://www.vagrantup.com/)
virtualbox | virtualbox VM
vm | only used as a qemu-kvm runner
vm-bootloader | same as vm, but uses a real bootloader instead of netbooting
vm-nogui | same as vm, but without a GUI
vmware | VMWare image (VMDK)

## Usage

Run `nixos-generate --help` for detailed usage information.

## select a specific nixpkgs channel

adds ability to select a specific channel version.

example:
```
nix-shell --command './nixos-generate -f iso -I nixpkgs=channel:nixos-19.09'
```

## Using a particular nixpkgs

To use features found in a different nixpkgs (for instance the Digital Ocean
image was recently merged in nixpkgs):

```
NIX_PATH=nixpkgs=../nixpkgs nixos-generate -f do
```

## Cross Compiling

To cross compile nixos images for other system you have
to configure `boot.binfmtMiscRegistrations` on your host system.

For more details about this have a look at :
[clevers qemu-user](https://github.com/cleverca22/nixos-configs/blob/master/qemu.nix).

Once you've run `nixos-rebuild` with theses options,
you can use the `--system` option to create images for other architectures.

### License

This project is licensed under the [MIT License](LICENSE).
