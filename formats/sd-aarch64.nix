{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  imports = [
    "${toString modulesPath}/installer/sd-card/sd-image-aarch64.nix"
  ];

  formatAttr = "sdImage";
  fileExtension = ".img.*";
}
