{modulesPath, ...}: {
  imports = [
    "${toString modulesPath}/virtualisation/vmware-image.nix"
  ];

  formatAttr = "vmwareImage";
  filename = ".vmdk";
}
