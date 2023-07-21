{
  config,
  pkgs,
  modulesPath,
  ...
}: {
  imports = [
    "${toString modulesPath}/virtualisation/lxc-container.nix"
  ];

  formatAttr = "metadata";
  filename = ".tar.xz";
}
