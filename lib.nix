{
  lib,
  options,
}: let
  # See https://github.com/NixOS/nixpkgs/commit/ccb85a53b6a496984073227fd8c4d4c58889f421
  # This commit changed the type of `system.build` from a lazy attribute set to
  # a submodule.  Prior to this commit, it doesn't make sense to qualify, e.g.
  # the `system.build.kexec_tarball` definition with `lib.mkForce`, as this
  # would result in setting the (final/resolved) value of
  # `system.build.kexec_tarball` to something like:
  #   {
  #     _type = "override";
  #     content = <...>;
  #     priority = 50;
  #   }
  # However, since this commit, `system.build.kexec_tarball` *must* be defined
  # using `lib.mkForce`; otherwise, Nix bails out with a complaint about
  # `system.build.kexec_tarball` being defined in multiple locations.
  systemBuildIsSubmodule = options.system.build.type.name == "submodule";

  optionsLookSane = lib.hasAttrByPath ["system" "build" "type" "name"] options;
in
  assert (lib.assertMsg optionsLookSane "`options' must be the NixOS module `options' argument"); {
    maybe =
      {
        mkForce = lib.id;
        mkOverride = _: lib.id;
      }
      // (lib.optionalAttrs systemBuildIsSubmodule {
        inherit (lib) mkForce mkOverride;
      });
  }
