{modulesPath, ...}: {
  imports = [
    "${toString modulesPath}/virtualisation/virtualbox-image.nix"
  ];

  formatAttr = "virtualBoxOVA";
  fileExtension = ".ova";
}
