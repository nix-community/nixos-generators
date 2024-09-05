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

  options = {
    boot = {
      consoles = lib.mkOption {
        default =
          ["ttyS0"]
          ++ (lib.optional (pkgs.stdenv.hostPlatform.isAarch) "ttyAMA0,115200")
          ++ (lib.optional (pkgs.stdenv.hostPlatform.isRiscV64) "ttySIF0,115200");
        description = "Kernel console boot flags to pass to boot.kernelParams";
        example = ["ttyS2,115200"];
      };

      diskSize = lib.mkOption {
        default = "auto";
        description = "The disk size in megabytes of the system disk image.";
        type = with lib.types; oneOf [ints.positive (enum ["auto"])];
      };
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
    boot.kernelParams = map (c: "console=${c}") config.boot.consoles;
    boot.loader.grub.device = "nodev";

    boot.loader.grub.efiSupport = true;
    boot.loader.grub.efiInstallAsRemovable = true;
    boot.loader.timeout = 0;

    system.build.qcow-efi = import "${toString modulesPath}/../lib/make-disk-image.nix" {
      inherit lib config pkgs;
      diskSize = config.boot.diskSize;
      format = "qcow2";
      partitionTableType = "efi";
    };

    formatAttr = "qcow-efi";
    fileExtension = ".qcow2";
  };
}
