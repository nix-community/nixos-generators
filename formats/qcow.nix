{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
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
  boot.kernelParams = ["console=ttyS0"];
  boot.loader.grub.device =
    if (pkgs.stdenv.system == "x86_64-linux")
    then (lib.mkDefault "/dev/vda")
    else (lib.mkDefault "nodev");

  boot.loader.grub.efiSupport = lib.mkIf (pkgs.stdenv.system != "x86_64-linux") (lib.mkDefault true);
  boot.loader.grub.efiInstallAsRemovable = lib.mkIf (pkgs.stdenv.system != "x86_64-linux") (lib.mkDefault true);
  boot.loader.timeout = 0;

  system.build.qcow = import "${toString modulesPath}/../lib/make-disk-image.nix" {
    inherit lib config pkgs;
    diskSize = 8192;
    format = "qcow2";
    partitionTableType = "hybrid";
  };

  formatAttr = "qcow";
  fileExtension = ".qcow2";
}
