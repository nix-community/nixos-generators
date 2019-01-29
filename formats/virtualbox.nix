{ modulesPath, ... }:
{
  imports = [
    "${modulesPath}/virtualisation/virtualbox-image.nix"
  ];

  formatAttr = "virtualBoxOVA";
}
