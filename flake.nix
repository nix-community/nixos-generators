{
  description = "nixos-generators - one config, multiple formats";

  # Lib dependency
  inputs.nixlib.url = "github:nix-community/nixpkgs.lib";

  # Bin dependency
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = { self, nixpkgs, nixlib }:

  # Library modules (depend on nixlib)
  {
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

    nixosGenerate = { pkgs ? null, lib ? nixpkgs.lib, format, system ? null, specialArgs ? { }, modules ? [ ], customFormats ? {} }:
    let 
      extraFormats = lib.mapAttrs' (name: value: lib.nameValuePair 
        (name) 
        (value // { 
          imports = ( value.imports or [] ++ [ ./format-module.nix ] ); 
        } )
        ) customFormats;
      formatModule = builtins.getAttr format (self.nixosModules // extraFormats);
      image = nixpkgs.lib.nixosSystem {
        inherit pkgs specialArgs;
        system = if system != null then system else pkgs.system;
        lib = if lib != null then lib else pkgs.lib;
        modules = [
          formatModule
        ] ++ modules;
      };
    in
      image.config.system.build.${image.config.formatAttr};

    # example usage in flakes:
    #   outputs = { self, nixpkgs, nixos-generators, ... }: {
    #     server = nixos-generators.nixosGenerateMulti {
    #       system = "x86_64-linux";
    #       modules = [./configuration.nix];
    #     } {
    #       "vm" = {  modules = [./qemuConfig.nix] };
    #       "vmware" = { modules = [./vmwareConfig.nix] };
    #     };
    #   }
    #
    # Builds multiple formats, based on common config. Takes a "default"
    # attribute set of parameters which are the same as for `nixos-generate`
    # and a second attribute set for each format.  The format specific
    # attribute should have a name which matches a valid nixos-generators
    # format, and have attributes which are merged with the provided defaults.
    # Generally, the format overrides the default with the exception that
    # modules are concatenated.  Each format is then available by name.  
    #
    # In the above example server.vm or server.vmware would build the qemu
    # vm or vmware formats, respectively.
    nixosGenerateMulti = baseArgs: formatArgs:
    let
      formats = nixpkgs.lib.attrNames formatArgs;
      mkFinalArgs = format: (nixpkgs.lib.recursiveUpdate baseArgs formatArgs.${format}) // { format = format; modules = baseArgs.modules ++ (formatArgs.${format}.modules or [ ]); };
      formatImage = format: (self.nixosGenerate (mkFinalArgs format));
      mkFormatAttr = format: nixpkgs.lib.nameValuePair format (formatImage format);
    in
    builtins.listToAttrs (map mkFormatAttr formats);

  }

  //


  # Binary and Devshell outputs (depend on nixpkgs)
  (
    let
       forAllSystems = nixpkgs.lib.genAttrs [ "x86_64-linux" "x86_64-darwin" "i686-linux" "aarch64-linux" "aarch64-darwin" ];
    in {

      packages = forAllSystems (system: let
        pkgs = nixpkgs.legacyPackages."${system}";
      in rec {
        nixos-generators = nixpkgs.lib.warn ''

          Deprecation note from: github:nix-community/nixos-generators

          Was renamed:

          Was: nixos-generators.packages.${system}.nixos-generators
          Now: nixos-generators.packages.${system}.nixos-generate

          Plase adapt your references
        '' nixos-generate;
        nixos-generate = pkgs.stdenv.mkDerivation {
          name = "nixos-generate";
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

      defaultPackage = forAllSystems (system: self.packages."${system}".nixos-generate);

      devShell = forAllSystems (system: let
        pkgs = nixpkgs.legacyPackages."${system}";
      in pkgs.mkShell {
        buildInputs = with pkgs; [ jq coreutils findutils ];
      });

      # Make it runnable with `nix run`
      apps = forAllSystems (system: let
        nixos-generate = {
          type    = "app";
          program = "${self.packages."${system}".nixos-generate}/bin/nixos-generate";
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
