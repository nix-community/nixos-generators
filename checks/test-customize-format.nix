{
  nixpkgs ? <nixpkgs>,
  system ? builtins.currentSystem,
  lib ? import (nixpkgs + /lib),
}: let
  nixosSystem = import (nixpkgs + /nixos/lib/eval-config.nix);

  userModule1 = {...}: {
    formatConfigs.amazon.amazonImage.name = "xyz";
  };

  userModule2 = {...}: {
    formatConfigs.amazon.amazonImage.name = lib.mkForce "custom-name";
  };

  conf = nixosSystem {
    inherit system;
    modules = [
      ../configuration.nix
      ../all-formats.nix
      userModule1
      userModule2
    ];
  };
in
  assert lib.hasInfix "custom-name" "${conf.config.formats.amazon}";
    conf.config.formats.amazon
