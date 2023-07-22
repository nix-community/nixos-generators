{modulesPath, ...}: {
  imports = [
    "${toString modulesPath}/virtualisation/digital-ocean-image.nix"
  ];

  formatAttr = "digitalOceanImage";
  fileExtension = ".qcow2.gz";
}
