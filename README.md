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
azure | Microsoft azure image
gce | Google Compute Image
install-iso | Installer ISO
iso | ISO
kexec | kexec tarball (extract to / and run /kexec_nixos)
kexec-bundle | same as before, but it's just an executable
openstack | qcow2 image for openstack
cloudstack | qcow2 image for cloudstack
qcow2 | qcow2 image
raw | raw image
virtualbox | virtualbox VM
vm | only used as a qemu-kvm runner
vm-nogui | same as before, but without a GUI
sd-aarch64-installer | create an installer sd card for aarch64. For cross compiling use `--system aarch64-linux` and read the cross-compile section.
sd-aarch64 | Like sd-aarch64-installer, but does not use default installer image config.

## Usage

Run `nixos-generate --help` for detailed usage information.

## Cross Compiling

To cross compile nixos images for other system you have
to configure `boot.binfmtMiscRegistrations` on your host system.

For more details about this have a look at :
[clevers qemu-user](https://github.com/cleverca22/nixos-configs/blob/master/qemu.nix).

Once you've run `nixos-rebuild` with theses options,
you can use the `--system` option to create images for other architectures.

### License

This project is licensed under the [MIT License](LICENSE).
