{lib, modulesPath, ...}: {
  imports = [
    "${toString modulesPath}/virtualisation/proxmox-lxc.nix"
  ];
  boot.loader.grub.enable = lib.mkForce false;
  boot.loader.systemd-boot.enable = lib.mkForce false;
  formatAttr = "tarball";
  fileExtension = ".tar.xz";
}
