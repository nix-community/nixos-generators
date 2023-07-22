{
  modulesPath,
  lib,
  ...
}: {
  imports = [
    "${toString modulesPath}/virtualisation/docker-image.nix"
  ];

  boot.isContainer = true;
  services.journald.console = "/dev/console";

  formatAttr = "tarball";
  fileExtension = ".tar.xz";
}
