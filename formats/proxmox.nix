{modulesPath, ...}: {
  imports = [
    "${toString modulesPath}/virtualisation/proxmox-image.nix"
  ];
  formatAttr = "VMA";
}
