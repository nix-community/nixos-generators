{ config, pkgs, lib, modulesPath, ... }:

{
  imports = [
    "${toString modulesPath}/virtualisation/lxc-container.nix"
  ];

  system.build.tarball = lib.mkForce (pkgs.callPackage "${toString modulesPath}/../lib/make-system-tarball.nix" {
    extraArgs = "--owner=0";
    storeContents = [
      {
        object = config.system.build.toplevel;
        symlink = "none";
      }
    ];
    contents = [
      {
        source = config.system.build.toplevel + "/init";
        target = "/sbin/init";
      }
    ];

    extraCommands = "mkdir -p proc sys dev";
  });

  formatAttr = "tarball";
  filename = "*/tarball/*.tar.xz";
}
