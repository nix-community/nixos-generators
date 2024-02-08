{modulesPath, ...}: {
  imports = [
    "${toString modulesPath}/virtualisation/azure-image.nix"
  ];

  formatAttr = "azureImage";
  fileExtension = ".vhd";
}
