{ config, lib, options, pkgs, modulesPath, ... }:

let
  inherit (import ../lib.nix { inherit lib options; }) maybe;
in {
  imports = [ ./raw.nix ];

  boot.loader.grub = {
    device = "nodev";
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  fileSystems."/boot" = {
    device = "/dev/vda1";
    fsType = "vfat";
  };

  system.build.raw = maybe.mkOverride 99 (import "${toString modulesPath}/../lib/make-disk-image.nix" {
    inherit lib config pkgs;
    partitionTableType = "efi";
    diskSize = "auto";
    format = "raw";
  });
}
