{ nixpkgs ? <nixpkgs>
, configuration ? <nixos-config>
, system ? builtins.currentSystem

, formatConfig

, flakeUri ? null
, flakeAttr ? null
}:
let
  module = rec {
      # ensures that this module has the same key as
      # the fromat-module that ships with 'nixos-generatores.nixosModules.*'.
      # Thereby, it will be deduplicated by the module system.
    _file = ./format-module.nix;
    key = _file;
    imports = [ ./format-module.nix];
  };

  # Will only get evaluated when used, so no worries
  flake = builtins.getFlake flakeUri;
  flakeSystem = flake.outputs.packages."${system}".nixosConfigurations."${flakeAttr}" or flake.outputs.nixosConfigurations."${flakeAttr}";
in
  if flakeUri != null then
    flakeSystem.extendModules {
      modules = [ module formatConfig ];
    }
  else
    import "${toString nixpkgs}/nixos/lib/eval-config.nix" {
      inherit system;
      modules = [
        (import ./format-module.nix)
        formatConfig
        configuration
      ];
    }
