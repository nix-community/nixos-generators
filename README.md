# nixos-generators - one config, multiple formats

The nixos-generators project allows to take the same NixOS configuration, and
generate outputs for different target formats.

Just put your stuff into the config.nix and then call one of the image builders.

for example:
```
./nixos-generate -f iso
```
or

```
./nixos-generate -f iso -c /etc/nixos/configuration.nix
```

it echoes the path to a iso image, which you then can flash onto an usb-stick
or mount & boot in a virtual machine.

## Supported formats

format | description
--- | ---
gce | Google Compute Image
install-iso | Installer ISO
iso | ISO 
kexec |
kexec-bundle |
openstack |
qcow2 |
raw |
virtualbox |
vm | only used as a qemu-kvm runner
vm-nogui | same as before, but without a GUI

## Usage

Run `./nixos-generate --help` for detailed usage information

### License
This project is licensed under the terms of the MIT license.
