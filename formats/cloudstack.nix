{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  imports = [
    "${toString modulesPath}/../maintainers/scripts/cloudstack/cloudstack-image.nix"
  ];

  fileSystems."/".fsType = lib.mkDefault "ext4";
  formatAttr = "cloudstackImage";
}
