{ config, ... }:
{
  imports = [
    <nixpkgs/nixos/modules/installer/cd-dvd/iso-image.nix>
  ];

  # EFI booting
  isoImage.makeEfiBootable = true;

  # USB booting
  isoImage.makeUsbBootable = true;

  formatAttr = "isoImage";
}
