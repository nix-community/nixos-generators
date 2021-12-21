{ modulesPath, ... }:
{
  imports = [
    "${toString modulesPath}/virtualisation/kubevirt.nix"
  ];

  formatAttr = "kubevirtImage";
}
