{
  nixpkgs ? <nixpkgs>,
  configuration ? <nixos-config>,
  system ? builtins.currentSystem,
  diskSize ? "auto",
  formatConfig,
  flakeUri ? null,
  flakeAttr ? null,
}: let
  module = import ./format-module.nix;

  # Will only get evaluated when used, so no worries
  flake = builtins.getFlake flakeUri;
  flakeSystem = flake.outputs.packages."${system}".nixosConfigurations."${flakeAttr}" or flake.outputs.nixosConfigurations."${flakeAttr}";
in
  if flakeUri != null
  then
    flakeSystem.extendModules {
      modules = [module formatConfig];
    }
  else
    import "${toString nixpkgs}/nixos/lib/eval-config.nix" {
      inherit system;
      specialArgs = {
        diskSize = diskSize;
      };
      modules = [
        module
        formatConfig
        configuration
      ];
    }
