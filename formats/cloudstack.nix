{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  imports = [
    "${toString modulesPath}/virtualisation/cloudstack-config.nix"
  ];

  fileSystems."/".fsType = lib.mkDefault "ext4";

  system.build.cloudstackImage = import "${toString modulesPath}/../lib/make-disk-image.nix" {
    inherit lib config pkgs;
    diskSize = 8192;
    format = "qcow2";
    configFile =
      pkgs.writeText "configuration.nix"
      ''
        {
          imports = [ "${toString modulesPath}/virtualisation/cloudstack-config.nix" ];
        }
      '';
  };

  formatAttr = "cloudstackImage";
}
