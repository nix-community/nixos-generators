{
  lib,
  modulesPath,
  ...
}: {
  imports = [
    "${toString modulesPath}/installer/cd-dvd/iso-image.nix"
  ];

  # EFI booting
  isoImage.makeEfiBootable = true;

  # USB booting
  isoImage.makeUsbBootable = true;

  # Much faster than xz
  isoImage.squashfsCompression = lib.mkDefault "zstd";

  formatAttr = "isoImage";
  fileExtension = ".iso";
}
