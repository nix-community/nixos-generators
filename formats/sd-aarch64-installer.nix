{ config, lib, modulesPath, files, ... }:
{
  imports = [
    "${toString modulesPath}/installer/cd-dvd/sd-image-aarch64.nix"
  ];

  sdImage.populateRootCommands = lib.foldr
    ({ source, target }: acc: acc + ''mkdir -p "$(dirname ${target})"'' +
      "\ncp ${source} ${target}\n") ""
    files;

  formatAttr = "sdImage";
}
