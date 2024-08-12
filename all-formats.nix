{
  config,
  lib,
  pkgs,
  extendModules,
  ...
}: let
  inherit
    (lib)
    types
    ;
  # attrs of all format modules from ./formats
  formatModules =
    lib.flip lib.mapAttrs' (builtins.readDir ./formats)
    (fname: type: {
      name = lib.removeSuffix ".nix" fname;
      value = ./formats + "/${fname}";
    });

  # function to evaluate a given format to a config
  evalFormat = formatModule:
    extendModules {
      modules = [
        ./format-module.nix
        formatModule
      ];
    };

  # evaluated configs for all formats
  allConfigs = lib.mapAttrs (formatName: evalFormat) config.formatConfigs;

  # adds an evaluated `config` to the derivation attributes of a format for introspection
  exposeConfig = conf: output: output.overrideAttrs (old: {
    passthru.config = conf.config;
  });

  # attrset of formats to be exposed under config.system.formats
  formats = lib.flip lib.mapAttrs allConfigs (
    formatName: conf: pkgs.runCommand "${conf.config.system.build.${conf.config.formatAttr}.name}${conf.config.fileExtension}" {} ''
      set -efu
      target=$(find '${conf.config.system.build.${conf.config.formatAttr}}' -name '*${conf.config.fileExtension}' -xtype f -print -quit)
      ln -s "$target" "$out"
    ''
  );
in {
  _file = ./all-formats.nix;
  # This deliberate key makes sure this module will be deduplicated
  # regardless of the accessor path: either via flake's nixosModule
  # or as part of the nixos-generate command. These two store paths
  # of the module may differ and hence don't serve as a key
  key = "github:nix-community/nixos-generators/all-formats.nix";

  # declare option for exposing all formats
  options.formats = lib.mkOption {
    type = lib.types.lazyAttrsOf lib.types.raw;
    description = ''
      Different target formats generated for this NixOS configuratation.
    '';
  };

  options.formatConfigs = lib.mkOption {
    type = types.attrsOf types.deferredModule;
  };

  # expose all formats
  config.formats = formats;

  #
  config.formatConfigs = lib.flip lib.mapAttrs formatModules (name: module: {
    imports = [module];
  });
}
