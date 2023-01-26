{ config, lib, pkgs, modulesPath, ... }:
{
  # for virtio kernel drivers
  imports = [
    "${toString modulesPath}/profiles/qemu-guest.nix"
  ];

  options = {
    diskSize = lib.mkOption {
      default = "auto";
      description = "The disk size in megabytes of the system disk image.";
      type = with lib.types; oneOf [ ints.positive (enum [ "auto" ])];
    };
  };

  config = {
    fileSystems."/" = {
      device = "/dev/disk/by-label/nixos";
      autoResize = true;
      fsType = "ext4";
    };

    fileSystems."/boot" = {
      device = "/dev/disk/by-label/ESP";
      fsType = "vfat";
    };

    boot.growPartition = true;
    boot.kernelParams = [ "console=ttyS0" ];
    boot.loader.grub.device = "nodev";

    boot.loader.grub.efiSupport = true;
    boot.loader.grub.efiInstallAsRemovable = true;
    boot.loader.timeout = 0;

    system.build.qcow = import "${toString modulesPath}/../lib/make-disk-image.nix" {
      inherit lib config pkgs;
      diskSize = config.diskSize;
      format = "qcow2";
      partitionTableType = "efi";
    };

    formatAttr = "qcow";
  };
}

