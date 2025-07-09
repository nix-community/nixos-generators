Starting with NixOS 25.05, most of nixos-generators has been upstreamed into nixpkgs.

So we believe it's time to retire nixos-generators, a good 7 years after its initial commit and after countless built images.
Please let us know if you run into any trouble, such as missing features, during the migration.

The main, user-visible difference is the new `nixos-rebuild build-image` command, which replaces the venerable `nixos-generate`.
Check its [manual section](https://nixos.org/manual/nixos/stable/#sec-image-nixos-rebuild-build-image) or below to see how it works.

# Usage of `nixos-rebuild build-images`

To build an ISO image, using the new `nixos-rebuild build-image`, run:

```
nixos-rebuild build-image --image-variant iso
```

Or to explicitly specifiy the path to your NixOS configuration as well as the nixpkgs checkout to use:

```
NIX_PATH=nixpkgs=../nixpkgs NIXOS_CONFIG="/etc/nixos/nixos-configuration.nix" nixos-rebuild build-image --image-variant iso
```

## ...with Flakes

To build a simple ISO image, from a `nixosConfigurations.myhost` output of your flake, run:

```
nixos-rebuild build-image --image-variant iso --flake .#myhost
```

Or, if you prefer to expose an installable similar to the old `nixos-generators.nixosGenerate` nix function,
you could use the right attribute of `system.build.images`:

``` nix
packages.x86_64-linux.myhost-iso = self.nixosConfigurations.myhost.config.system.build.images.iso
```

# Formats of `nixos-generators`

The third column describes whether they are supported image variants in `nixos-rebuild build-image`:

format | description | supported in nixpkgs
--- | --- | ---
amazon | Amazon EC2 image | ✅
azure | Microsoft azure image (Generation 1 / VHD) |  ✅
cloudstack | qcow2 image for cloudstack. | [Not yet merged](https://github.com/NixOS/nixpkgs/pull/398556) at time of writing.
do | Digital Ocean image | ✅
docker | Docker image (uses systemd to run, probably only works in podman)
gce | Google Compute image | ✅
hyperv | Hyper-V Image (Generation 2 / VHDX) | ✅
install-iso | Installer ISO |  ✅ (called `iso-installer`)
install-iso-hyperv | Installer ISO with enabled hyper-v support | use the `hyperv` variant and [customize it](https://nixos.org/manual/nixos/stable/#sec-image-nixos-rebuild-build-image-customize).
iso | ISO | ✅
kexec | kexec tarball (extract to / and run /kexec_nixos) | ✅
kexec-bundle | same as before, but it's just an executable | Use the `kexec` variant above.
kubevirt | KubeVirt image |  ✅
linode | Linode image |  ✅
lxc | create a tarball which is importable as an lxc container, use together with lxc-metadata |  ✅
lxc-metadata | the necessary metadata for the lxc image to start, usage: `lxc image import $(nixos-generate -f lxc-metadata) $(nixos-generate -f lxc)` |  ✅
openstack | qcow2 image for openstack |  ✅
proxmox | [VMA](https://pve.proxmox.com/wiki/VMA) file for proxmox |  ✅
proxmox-lxc | LXC template for proxmox |  ✅
qcow | qcow2 image |  ✅
qcow-efi | qcow2 image with efi support |  ✅
raw | raw image with bios/mbr. for physical hardware, see the 'raw and raw-efi' section |  ✅
raw-efi | raw image with efi support. for physical hardware, see the 'raw and raw-efi' section |  ✅
sd-aarch64 | Like sd-aarch64-installer, but does not use default installer image config. | use `sd-card` and set `system` to `aarch64-linux`
sd-aarch64-installer | create an installer sd card for aarch64. For cross compiling use `--system aarch64-linux` and read the cross-compile section. | use `sd-card` and set `system` to `aarch64-linux`
sd-x86_64 | sd card image for x86_64 systems | use `sd-card` and set `system` to `x86_64-linux`
vagrant-virtualbox | VirtualBox image for [Vagrant](https://www.vagrantup.com/)|  ✅
virtualbox | virtualbox VM|  ✅
vm | only used as a qemu-kvm runner | use `nixos-rebuild build-vm`
vm-bootloader | same as vm, but uses a real bootloader instead of netbooting | use `nixos-rebuild build-vm-with-bootloader`
vm-nogui | same as vm, but without a GUI | use `nixos-rebuild build-vm` and [customize it](https://nixos.org/manual/nixos/stable/#sec-image-nixos-rebuild-build-image-customize).
vmware | VMWare image (VMDK) |  ✅
