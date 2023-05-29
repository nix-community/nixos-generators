{
  nixpkgs ? import <nixpkgs> {},
}: let
  nixosSystem = import (nixpkgs.path + /nixos/lib/eval-config.nix);
  conf = nixosSystem {
    modules = [
      ./configuration.nix
      ./all-formats.nix
    ];
  };
in
conf.config.system.formats
