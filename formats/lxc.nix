{ config, pkgs, lib, modulesPath, ... }: let
  pkgs2storeContents = l : map (x: { object = x; symlink = "none"; }) l;
in {
  imports = [
    "${toString modulesPath}/virtualisation/lxc-container.nix"
  ];

  system.build.tarball = lib.mkForce (pkgs.callPackage <nixpkgs/nixos/lib/make-system-tarball.nix> {
    contents = [];
    extraArgs = "--owner=0";
    storeContents = [
      {
        object = config.system.build.toplevel + "/init";
        symlink = "/sbin/init";
      }
    ] ++ (pkgs2storeContents [ pkgs.stdenv ]);

    extraCommands = "mkdir -p proc sys dev";
  });

  formatAttr = "tarball";
}
