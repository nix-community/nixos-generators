{modulesPath, ...}: {
  imports = [
    "${toString modulesPath}/virtualisation/proxmox-lxc.nix"
  ];
  formatAttr = "tarball";
  filename = ".tar.xz";
}
