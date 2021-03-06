{ config, lib, pkgs, modulesPath, ... }:
{
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
    diskSize = 8192;
    format = "qcow2";
  };

  formatAttr = "qcow";
}
