{ modulesPath, ... }:
{
  imports = [
    "${modulesPath}/virtualisation/azure-image.nix"
  ];

  formatAttr = "azureImage";
}
