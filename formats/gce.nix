{ modulesPath, ... }:
{
  imports = [
    "${modulesPath}/virtualisation/google-compute-image.nix"
  ];

  formatAttr = "googleComputeImage";
}
