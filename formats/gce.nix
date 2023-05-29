{modulesPath, ...}: {
  imports = [
    "${toString modulesPath}/virtualisation/google-compute-image.nix"
  ];

  formatAttr = "googleComputeImage";
}
