{ nixpkgs ? <nixpkgs>
, configuration ? <nixos-config>
, system ? builtins.currentSystem

, formatConfig

, flakeUri ? null
, flakeAttr ? null
, memory ? null
}:
let
  lib = (import "${toString nixpkgs}/lib/default.nix");

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

    config = {
    } // lib.optionalAttrs (memory != null) { virtualisation.memorySize = memory; };
  };

  # Will only get evaluated when used, so no worries
  flake = builtins.getFlake flakeUri;
  flakeSystem = flake.outputs.packages."${system}".nixosConfigurations."${flakeAttr}" or flake.outputs.nixosConfigurations."${flakeAttr}";
in
  if flakeUri != null then
    flakeSystem.override (attrs: {
      modules = attrs.modules ++ [ module formatConfig ];
    })
  else
    import "${toString nixpkgs}/nixos/lib/eval-config.nix" {
      inherit system;
      modules = [
        module
        formatConfig
        configuration
      ];
    }
