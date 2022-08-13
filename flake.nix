{
  description = "nixos-generators - one config, multiple formats";

  # Lib dependency
  inputs.nixlib.url = "github:nix-community/nixpkgs.lib";

  # Bin dependency
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = { self, nixpkgs, nixlib }:

  # Library modules (depend on nixlib)
  rec {
    # export all generator formats in ./formats
    nixosModules = nixlib.lib.mapAttrs' (file: _: {
      name = nixlib.lib.removeSuffix ".nix" file;
      # The exported module should include the internal format* options
      value.imports = [ (./formats + "/${file}") ./format-module.nix ];
    }) (builtins.readDir ./formats);

    # example usage in flakes:
    #   outputs = { self, nixpkgs, nixos-generators, ...}: {
    #     vmware = nixos-generators.nixosGenerate {
    #       system = "x86_64-linux";
    #       modules = [./configuration.nix];
    #       format = "vmware";
    #   };
    # }
    nixosGenerate = { pkgs ? null, format,  system ? null, specialArgs ? { }, modules ? [ ] }:
    let 
      formatModule = builtins.getAttr format nixosModules;
      image = nixpkgs.lib.nixosSystem {
        inherit pkgs specialArgs;
        system = if system != null then system else pkgs.system;
        modules = [
          formatModule
        ] ++ modules;
      };
    in
      image.config.system.build.${image.config.formatAttr};

  }

  //


  # Binary and Devshell outputs (depend on nixpkgs)
  (
    let
       forAllSystems = nixpkgs.lib.genAttrs [ "x86_64-linux" "x86_64-darwin" "i686-linux" "aarch64-linux" ];
    in {

      packages = forAllSystems (system: let
        pkgs = nixpkgs.legacyPackages."${system}";
      in {
        nixos-generators = pkgs.stdenv.mkDerivation {
          name = "nixos-generators";
          src = ./.;
          meta.description = "Collection of image builders";
          nativeBuildInputs = with pkgs; [ makeWrapper ];
          installFlags = [ "PREFIX=$(out)" ];
          postFixup = ''
            wrapProgram $out/bin/nixos-generate \
              --prefix PATH : ${pkgs.lib.makeBinPath (with pkgs; [ jq coreutils findutils ])}
          '';
        };
      });

      defaultPackage = forAllSystems (system: self.packages."${system}".nixos-generators);

      devShell = forAllSystems (system: let
        pkgs = nixpkgs.legacyPackages."${system}";
      in pkgs.mkShell {
        buildInputs = with pkgs; [ jq coreutils findutils ];
      });

      # Make it runnable with `nix run`
      apps = forAllSystems (system: let
        nixos-generate = {
          type    = "app";
          program = "${self.packages."${system}".nixos-generators}/bin/nixos-generate";
        };
      in {
        inherit nixos-generate;

        # Nix >= 2.7 flake output schema uses `apps.<system>.default` instead
        # of `defaultApp.<system>` to signify the default app (the thing that
        # gets run with `nix run . -- <args>`)
        default = nixos-generate;
      });

      defaultApp = forAllSystems (system: self.apps."${system}".nixos-generate);
    }
  );
}
