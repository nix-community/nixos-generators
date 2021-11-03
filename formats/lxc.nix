{ config, pkgs, lib, modulesPath, ... }:

{
  imports = [
    "${toString modulesPath}/virtualisation/lxc-container.nix"
  ];

  formatAttr = "tarball";
  filename = "*/tarball/*.tar.xz";
}
