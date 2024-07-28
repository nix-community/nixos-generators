{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  imports = [
    "${toString modulesPath}/installer/sd-card/sd-image-x86_64.nix"
  ];

  formatAttr = "sdImage";
  fileExtension = ".img.*";
}
