{ config, lib, pkgs, modulesPath, ... }:
{
  imports = [ ./raw.nix ];

  boot.loader.grub = {
    device = "nodev";
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  system.build.raw = lib.mkOverride 999 (import "${toString modulesPath}/../lib/make-disk-image.nix" {
    inherit lib config pkgs;
    partitionTableType = "efi";
    diskSize = 2048;
    format = "raw";
  });
}
