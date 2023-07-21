{modulesPath, ...}: {
  imports = [
    "${toString modulesPath}/virtualisation/digital-ocean-image.nix"
  ];

  formatAttr = "digitalOceanImage";
  filename = ".qcow2.gz";
}
