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

nixos-generators is part of [nixpkgs](https://search.nixos.org/packages?channel=unstable&show=nixos-generators&from=0&size=50&sort=relevance&type=packages&query=nixos-generator) and can be installed from there.

nixos-generators can be also installed from source into the user profile like this:

```console
nix-env -f https://github.com/nix-community/nixos-generators/archive/master.tar.gz -i
```

or for flakes users like this:

```console
nix profile install github:nix-community/nixos-generators
```

or run from the nix flake without installing:

```
nix run github:nix-community/nixos-generators -- --help
```

## Supported formats

format | description
--- | ---
amazon | Amazon EC2 image
azure | Microsoft azure image (Generation 1 / VHD)
cloudstack | qcow2 image for cloudstack
do | Digital Ocean image
docker | Docker image (uses systemd to run, probably only works in podman)
gce | Google Compute image
hyperv | Hyper-V Image (Generation 2 / VHDX)
install-iso | Installer ISO
install-iso-hyperv | Installer ISO with enabled hyper-v support
iso | ISO
kexec | kexec tarball (extract to / and run /kexec_nixos)
kexec-bundle | same as before, but it's just an executable
kubevirt | KubeVirt image
lxc | create a tarball which is importable as an lxc container, use together with lxc-metadata
lxc-metadata | the necessary metadata for the lxc image to start, usage: lxc image import $(nixos-generate -f lxc-metadata) $(nixos-generate -f lxc)
openstack | qcow2 image for openstack
proxmox | [VMA](https://pve.proxmox.com/wiki/VMA) file for proxmox
proxmox-lxc | LXC template for proxmox
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

To cross compile nixos images for other architectures you have to configure
`boot.binfmt.emulatedSystems` or `boot.binfmt.registrations` on your host system.

In your system `configuration.nix`:
```nix
{
  # Enable binfmt emulation of aarch64-linux.
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
}
```

Alternatively, if you want to target other architectures:
```nix
# Define qemu-arm-static source.
let qemu-arm-static = pkgs.stdenv.mkDerivation {
  name = "qemu-arm-static";
  src = builtins.fetchurl {
    url = "https://github.com/multiarch/qemu-user-static/releases/download/v6.1.0-8/qemu-arm-static";
    sha256 = "06344d77d4f08b3e1b26ff440cb115179c63ca8047afb978602d7922a51231e3";
  };
  dontUnpack = true;
  installPhase = "install -D -m 0755 $src $out/bin/qemu-arm-static";
};
in {
  # Enable binfmt emulation of extra binary formats (armv7l-linux, for exmaple).
  boot.binfmt.registrations.arm = {
    interpreter = "${qemu-arm-static}/bin/qemu-arm-static";
    magicOrExtension = ''\x7fELF\x01\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x28\x00'';
    mask = ''\xff\xff\xff\xff\xff\xff\xff\x00\xff\xff\xff\xff\xff\xff\x00\xff\xfe\xff\xff\xff'';
  };

  # Define additional settings for nix.
  nix.extraOptions = ''
    extra-platforms = armv7l-linux
  '';
  nix.sandboxPaths = [ "/run/binfmt/arm=${qemu-arm-static}/bin/qemu-arm-static" ];
}
```

For more details on configuring `binfmt`, have a look at:
[binfmt options](https://search.nixos.org/options?channel=unstable&query=boot.binfmt),
[binfmt.nix](https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/system/boot/binfmt.nix),
[this comment](https://github.com/NixOS/nixpkgs/issues/109661#issuecomment-762629438) and
[clevers qemu-user](https://github.com/cleverca22/nixos-configs/blob/master/qemu.nix).

Once you've run `nixos-rebuild` with these options,
you can use the `--system` option to create images for other architectures.

## Using in a Flake

`nixos-generators` can be included as a `Flake` input and provides
a `nixos-generate` function for building images as `Flake` outputs. This
approach pins all dependencies and allows for conveniently defining multiple
output types based on one config. 

An example `flake.nix` demonstrating this approach is below. `vmware` or
`virtualbox` images can be built from the same `configuration.nix` by running
`nix build .#vmware` or `nix build .#virtualbox`

```nix
{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { self, nixpkgs, nixos-generators, ... }: {
    packages.x86_64-linux = {
      vmware = nixos-generators.nixosGenerate {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        modules = [
          # you can include your own nixos configuration here, i.e.
          # ./configuration.nix
        ];
        format = "vmware";
      };
      vbox = nixos-generators.nixosGenerate {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        format = "virtualbox";
      };
    };
  };
}
```

### License

This project is licensed under the [MIT License](LICENSE).

# FAQ

#### No space left on device

this means either /tmp, /run/user/$UID or your TMPFS runs full. sometimes setting TMPDIR to some other location can help, sometimes /tmp needs to be on a bigger partition (not a tmpfs).
