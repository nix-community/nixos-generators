{ config, modulesPath, ... }:
{
  imports = [
    "${toString modulesPath}/installer/cd-dvd/sd-image-aarch64.nix"
  ];

  formatAttr = "sdImage";
}
