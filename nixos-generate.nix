{ nixpkgs ? <nixpkgs>
, configuration ? <nixos-config>
, format-config ? <format-config>
, system ? builtins.currentSystem
}:
let
  module = { lib, ... }: {
    options = {
      filename = lib.mkOption {
        type = lib.types.str;
        description = "Declare the path of the wanted file in the output directory";
        default = "*";
      };
      formatAttr = lib.mkOption {
        type = lib.types.str;
        description = "Declare the default attribute to build";
      };
    };
  };
in
import "${toString nixpkgs}/nixos/lib/eval-config.nix" {
  inherit system;
  modules = [
    module
    format-config
    configuration
  ];
}
