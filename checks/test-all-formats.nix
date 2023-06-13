{
  nixpkgs ? <nixpkgs>,
  system ? builtins.currentSystem,
  lib ? import (nixpkgs + /lib),
}: let
  nixosSystem = import (nixpkgs + /nixos/lib/eval-config.nix);

  conf = nixosSystem {
    inherit system;
    modules = [
      ../configuration.nix
      ../all-formats.nix
    ];
  };

  exclude =
    (lib.optionalAttrs (system != "aarch64-linux") {
      sd-aarch64 = true;
      sd-aarch64-installer = true;
    })
    // (lib.optionalAttrs (system != "x86_64-linux") {
      azure = true;
      vagrant-virtualbox = true;
      virtualbox = true;
      vmware = true;
    });

  testedFormats =
    lib.filterAttrs
    (name: _: ! exclude ? ${name})
    conf.config.system.formats;
in
  testedFormats
