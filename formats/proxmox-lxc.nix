{ modulesPath, ... }:
{
  imports = [
    "${toString modulesPath}/virtualisation/proxmox-lxc.nix"
  ];
  formatAttr = "tarball";
  filename = "*/tarball/*.tar.xz";
}
