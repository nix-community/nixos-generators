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

      # Make it runnable with `nix app`
      apps = forAllSystems (system: {
        nixos-generate = {
          type    = "app";
          program = "${self.packages."${system}".nixos-generators}/bin/nixos-generate";
        };
      });

      defaultApp = forAllSystems (system: self.apps."${system}".nixos-generate);
    }
  );
}
