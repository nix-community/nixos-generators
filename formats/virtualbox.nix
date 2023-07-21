{modulesPath, ...}: {
  imports = [
    "${toString modulesPath}/virtualisation/virtualbox-image.nix"
  ];

  formatAttr = "virtualBoxOVA";
  filename = ".ova";
}
