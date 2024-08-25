{
  config,
  lib,
  pkgs,
  modulesPath,
  specialArgs,
  ...
}: let
  consoles = [ "ttyS0" ] ++
    (lib.optional (pkgs.stdenv.hostPlatform.isAarch) "ttyAMA0,115200") ++
    (lib.optional (pkgs.stdenv.hostPlatform.isRiscV64) "ttySIF0,115200");
in {
  # for virtio kernel drivers
  imports = [
    "${toString modulesPath}/profiles/qemu-guest.nix"
  ];

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
  boot.kernelParams = map (c: "console=${c}") consoles;
  boot.loader.grub.device = "nodev";

  boot.loader.grub.efiSupport = true;
  boot.loader.grub.efiInstallAsRemovable = true;
  boot.loader.timeout = 0;

  system.build.qcow-efi = import "${toString modulesPath}/../lib/make-disk-image.nix" ({
    inherit lib config pkgs;
    diskSize = specialArgs.diskSize or "auto";
    format = "qcow2";
    partitionTableType = "efi";
  } // (lib.optionalAttrs ((builtins.hasAttr "bootSize" specialArgs) && specialArgs.bootSize != null) {
    bootSize = "${builtins.toString specialArgs.bootSize}M";
  }));

  formatAttr = "qcow-efi";
  fileExtension = ".qcow2";
}
