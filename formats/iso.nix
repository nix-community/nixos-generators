{ config, modulesPath, files, ... }:
{
  imports = [
    "${toString modulesPath}/installer/cd-dvd/iso-image.nix"
  ];

  # EFI booting
  isoImage.makeEfiBootable = true;

  # USB booting
  isoImage.makeUsbBootable = true;

  isoImage.contents = files;

  formatAttr = "isoImage";
  filename = "*.iso";
}
