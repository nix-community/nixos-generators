{ config, lib, pkgs, modulesPath, ... }:
{
  options = {
    virtualization.qemuImage.diskSize = mkOption {
      type = types.int;
      default = 8192;
      description = ''
        Size of disk image. Unit is MB.
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
      diskSize = config.virtualization.qemuImage.diskSize;
      format = "qcow2";
    };

    formatAttr = "qcow";
  };
}
