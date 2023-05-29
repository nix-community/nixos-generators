{ lib, extendModules, ... }: let

  # attrs of all format modules from ./formats
  formatModules = lib.flip lib.mapAttrs' (builtins.readDir ./formats)
    (fname: type: {
      name = lib.removeSuffix ".nix" fname;
      value = ./formats + "/${fname}";
    });

  # function to evaluate a given format to a config
  evalFormat = formatModule: extendModules {
    modules = [
      ./format-module.nix
      formatModule
    ];
  };

  # evaluated configs for all formats
  allConfigs = lib.mapAttrs (formatName: evalFormat) formatModules;

  # attrset of formats to be exposed under config.system.formats
  formats = lib.flip lib.mapAttrs allConfigs (
    formatName: conf:
      conf.config.system.build.${conf.config.formatAttr}
  );

in {
  _file = ./all-formats.nix;
  # This deliberate key makes sure this module will be deduplicated
  # regardless of the accessor path: either via flake's nixosModule
  # or as part of the nixos-generate command. These two store paths
  # of the module may differ and hence don't serve as a key
  key = "github:nix-community/nixos-generators/all-formats.nix";

  # declare option for exposing all formats
  options.system.formats = lib.mkOption {
    type = lib.types.lazyAttrsOf lib.types.raw;
    description = ''
      Different target formats generated for this NixOS configuratation.
    '';
  };

  # expose all formats
  config.system = {inherit formats;};
}

