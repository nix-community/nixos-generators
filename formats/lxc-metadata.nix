{
  config,
  lib,
  modulesPath,
  pkgs,
  ...
}: {
  imports = [
    "${toString modulesPath}/virtualisation/lxc-container.nix"
  ];

  boot.loader.grub.enable = lib.mkForce false;
  boot.loader.systemd-boot.enable = lib.mkForce false;
  formatAttr = "metadata";
  fileExtension = ".tar.xz";
}
