{ config, lib, pkgs, modulesPath, ... }:
{
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    autoResize = true;
  };

  boot.growPartition = true;
  boot.kernelParams = [ "console=ttyS0" ];
  boot.loader.grub.device = lib.mkDefault "/dev/vda";
  boot.loader.timeout = 0;


  system.build.raw = import "${toString modulesPath}/../lib/make-disk-image.nix" {
    inherit lib config pkgs;
    diskSize = 2048;
    format = "raw";
  };

  formatAttr = "raw";
}
