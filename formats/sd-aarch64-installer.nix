{ config, modulesPath, ... }:
{
  imports = [
    "${toString modulesPath}/installer/sd-card/sd-image-aarch64-installer.nix"
  ];

  formatAttr = "sdImage";
}
