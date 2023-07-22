{modulesPath, ...}: {
  imports = [
    "${toString modulesPath}/virtualisation/google-compute-image.nix"
  ];

  formatAttr = "googleComputeImage";
  fileExtension = ".raw.tar.gz";
}
