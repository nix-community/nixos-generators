{modulesPath, ...}: {
  imports = [
    "${toString modulesPath}/virtualisation/digital-ocean-image.nix"
  ];

  formatAttr = "digitalOceanImage";
}
