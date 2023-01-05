{ config, lib, pkgs, modulesPath, ... }:
{
  # for virtio kernel drivers
  imports = [
    "${toString modulesPath}/profiles/qemu-guest.nix"
  ];

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    autoResize = true;
    fsType = "ext4";
  };

  boot.growPartition = true;
  boot.kernelParams = [ "console=ttyS0" ];
  boot.loader.grub.device = "nodev";

  boot.loader.grub.efiSupport = true;
  boot.loader.grub.efiInstallAsRemovable = true;
  boot.loader.timeout = 0;

  system.build.qcow = import "${toString modulesPath}/../lib/make-disk-image.nix" {
    inherit lib config pkgs;
    diskSize = 2048;
    format = "qcow2";
    partitionTableType = "efi";
  };

  formatAttr = "qcow";
}

