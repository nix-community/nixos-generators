{
  description = "nixos-generators - one config, multiple formats";

  # Lib dependency
  inputs.nixlib.url = "github:nix-community/nixpkgs.lib";

  # Bin dependency
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = {
    self,
    nixpkgs,
    nixlib,
  } @ inputs: let
    lib = nixpkgs.lib;

    callFlake = flake: let
      args =
        inputs
        // {
          nixos-generators = self;
          self = subFlake;
        };
      subFlake = (import flake).outputs args;
    in
      subFlake;

    # Ensures a derivation's name can be accessed without evaluating it deeply.
    # Prevents `nix flake show` from being very slow.
    makeLazyDrv = name: drv: {
      inherit name;
      inherit
        (drv)
        drvPath
        outPath
        outputName
        system
        ;
      type = "derivation";
    };
  in
    # Library modules (depend on nixlib)
    {
      # export all generator formats in ./formats
      nixosModules =
        {
          all-formats = ./all-formats.nix;
        }
        // (nixlib.lib.mapAttrs' (file: _: {
          name = nixlib.lib.removeSuffix ".nix" file;
          # The exported module should include the internal format* options
          value.imports = [(./formats + "/${file}") ./format-module.nix];
        }) (builtins.readDir ./formats));

      # example usage in flakes:
      #   outputs = { self, nixpkgs, nixos-generators, ...}: {
      #     vmware = nixos-generators.nixosGenerate {
      #       system = "x86_64-linux";
      #       modules = [./configuration.nix];
      #       format = "vmware";
      #   };
      # }

      nixosGenerate = {
        pkgs ? null,
        lib ? nixpkgs.lib,
        nixosSystem ? nixpkgs.lib.nixosSystem,
        nixosConfig ? { },
        format,
        system ? null,
        specialArgs ? {},
        modules ? [],
        customFormats ? {},
      }: let
        extraFormats =
          lib.mapAttrs' (
            name: value:
              lib.nameValuePair
              name
              {
                imports = [
                  value
                  ./format-module.nix
                ];
              }
          )
          customFormats;
        formatModule = builtins.getAttr format (self.nixosModules // extraFormats);
        image = nixosSystem {
          inherit pkgs specialArgs;
          system =
            if system != null
            then system
            else pkgs.system;
          lib =
            if lib != null
            then lib
            else pkgs.lib;
          modules =
            [
              formatModule
            ]
            ++ modules;
        } // nixosConfig;
      in
        image.config.system.build.${image.config.formatAttr};
    }
    //
    # Binary and Devshell outputs (depend on nixpkgs)
    (
      let
        forAllSystems = nixpkgs.lib.genAttrs ["x86_64-linux" "x86_64-darwin" "i686-linux" "aarch64-linux" "aarch64-darwin"];
      in {
        formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);

        packages = forAllSystems (system: let
          pkgs = nixpkgs.legacyPackages."${system}";
        in rec {
          default = nixos-generate;
          nixos-generate = pkgs.callPackage ./package.nix {};
        });

        checks =
          lib.recursiveUpdate
          (callFlake ./checks/test-all-formats-flake/flake.nix).checks
          (
            lib.genAttrs [
              "x86_64-linux"
              # We currently don't have kvm support on our builder
              #"aarch64-linux"
            ]
            (
              system: let
                allFormats = import ./checks/test-all-formats.nix {
                  inherit nixpkgs system;
                };
                test-customize-format = import ./checks/test-customize-format.nix {
                  inherit nixpkgs system;
                };
              in
                lib.mapAttrs makeLazyDrv (
                  {
                    inherit
                      (self.packages.${system})
                      nixos-generate
                      ;

                    inherit test-customize-format;

                    is-formatted = import ./checks/is-formatted.nix {
                      pkgs = nixpkgs.legacyPackages.${system};
                    };
                  }
                  // allFormats
                )
            )
          );

        devShells = forAllSystems (system: let
          pkgs = nixpkgs.legacyPackages."${system}";
        in {
          default = pkgs.mkShell {
            buildInputs = with pkgs; [jq coreutils findutils];
          };
        });

        # Make it runnable with `nix run`
        apps = forAllSystems (system: let
          nixos-generate = {
            type = "app";
            program = "${self.packages."${system}".nixos-generate}/bin/nixos-generate";
          };
        in {
          inherit nixos-generate;

          # Nix >= 2.7 flake output schema uses `apps.<system>.default` instead
          # of `defaultApp.<system>` to signify the default app (the thing that
          # gets run with `nix run . -- <args>`)
          default = nixos-generate;
        });
      }
    );
}
