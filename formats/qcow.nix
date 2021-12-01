{ config, lib, pkgs, modulesPath, ... }:

with lib;

{
  # for virtio kernel drivers
  imports = [
    "${toString modulesPath}/profiles/qemu-guest.nix"
  ];

  options = {
    virtualisation.qemuImage.diskSize = mkOption {
      type = types.int;
      default = 8192;
      description = ''
        Size of disk image in MiB.
      '';
    };
  };

  config = {
    fileSystems."/" = {
      device = "/dev/disk/by-label/nixos";
      autoResize = true;
      fsType = "ext4";
    };

    boot.growPartition = true;
    boot.kernelParams = [ "console=ttyS0" ];
    boot.loader.grub.device = lib.mkDefault "/dev/vda";
    boot.loader.timeout = 0;

    system.build.qcow = import "${toString modulesPath}/../lib/make-disk-image.nix" {
      inherit lib config pkgs;
      diskSize = config.virtualisation.qemuImage.diskSize;
      format = "qcow2";
    };

    formatAttr = "qcow";
  };
}
