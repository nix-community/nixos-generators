{modulesPath, ...}: {
  imports = [
    "${toString modulesPath}/virtualisation/google-compute-image.nix"
  ];

  formatAttr = "googleComputeImage";
  filename = ".raw.tar.gz";
}
