{modulesPath, ...}: {
  imports = [
    "${toString modulesPath}/virtualisation/hyperv-image.nix"
  ];

  formatAttr = "hypervImage";
  filename = ".vhdx";
}
