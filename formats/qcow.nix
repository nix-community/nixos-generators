{ config, lib, pkgs, ... }:
{
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    autoResize = true;
  };

  boot.growPartition = true;
  boot.kernelParams = [ "console=ttyS0" ];
  boot.loader.grub.device = "/dev/vda";
  boot.loader.timeout = 0;


  system.build.qcow = import <nixpkgs/nixos/lib/make-disk-image.nix> {
    inherit lib config pkgs;
    diskSize = 8192;
    format = "qcow2";
  };

  formatAttr = "qcow";
}
