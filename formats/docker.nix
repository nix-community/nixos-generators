{
  modulesPath,
  lib,
  ...
}: {
  imports = [
    "${toString modulesPath}/virtualisation/docker-image.nix"
  ];

  boot.isContainer = true;
  boot.loader.grub.enable = lib.mkForce false;
  boot.loader.systemd-boot.enable = lib.mkForce false;
  services.journald.console = "/dev/console";

  formatAttr = "tarball";
  fileExtension = ".tar.xz";
}
