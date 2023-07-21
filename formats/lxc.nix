{
  config,
  pkgs,
  lib,
  modulesPath,
  ...
}: {
  imports = [
    "${toString modulesPath}/virtualisation/lxc-container.nix"
  ];

  formatAttr = "tarball";
  filename = ".tar.xz";
}
