{
  description = "nixos-generators - one config, multiple formats";

  # Lib dependency
  inputs.nixlib.url = "github:nix-community/nixpkgs.lib";

  # Bin dependency
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.nixos.url = "github:NixOS/nixpkgs/nixos-21.11";

  outputs = { self, nixpkgs, nixos, nixlib }@inputs:

  # Library modules (depend on nixlib)
  rec {
    # export all generator formats in ./formats
    nixosModules = nixlib.lib.mapAttrs' (file: _: {
      name = nixlib.lib.removeSuffix ".nix" file;
      # The exported module should include the internal format* options
      value.imports = [ (./formats + "/${file}") ./format-module.nix ];
    }) (builtins.readDir ./formats);

    nixosGenerate' = {
      format
    , system
    , nixpkgs ? inputs.nixpkgs
    , pkgs ? nixpkgs.legacyPackages.${system}
    , specialArgs ? { }
    , modules ? [ ]
    }:
    let
      formatModule = builtins.getAttr format nixosModules;
      image = nixpkgs.lib.nixosSystem {
        inherit pkgs specialArgs;
        system = pkgs.system;
        modules = [
          formatModule
        ] ++ modules;
      };
    in assert system == pkgs.system;
      image.config.system.build.${image.config.formatAttr};

    # example usage in flakes:
    #   outputs = { self, nixpkgs, nixos-generators, ...}: {
    #     vmware = nixos-generators.nixosGenerate {
    #       pkgs = nixpkgs.legacyPackages.x86_64-linux;
    #       modules = [./configuration.nix];
    #       format = "vmware";
    #   };
    # }
    nixosGenerate = { pkgs, format, specialArgs ? { }, modules ? [ ] }:
      nixosGenerate' {
        system = pkgs.system;
        inherit pkgs format specialArgs modules;
      };
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

      checks = let
        # No way to limit `nix flake check` to a subset of supported systems;
        # see https://github.com/NixOS/nix/issues/6398.
        forCheckSystems = nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-linux" ];

        checksForNixpkgs =
          system:
          {
            input,
            id,
            modules ? (fetchModules system id)
          }:
        let
          pkgs = input.legacyPackages.${system};
          generateFormat = format: self.nixosGenerate' {
            inherit format system pkgs;
            nixpkgs = input;
          };
          #formatModules = builtins.removeAttrs self.nixosModules exclude;
        in nixlib.lib.mapAttrs' (format: _: let
          name = "${format}-${id}";
          diag = ''evaluating format "${format}" using nixpkgs input "${id}" on system "${system}"'';
          value = nixlib.lib.trace diag (generateFormat format);
        in {
          inherit name value;
        }) modules;

        fetchModules = let
          excludeCommon = [
            # error:
            #      Failed assertions:
            #      - Mountpoint '/': 'autoResize = true' is not supported for 'fsType = "auto"': fsType has to be explicitly set and only the ext filesystems and f2fs support it.
            "cloudstack"

            # error (ignored): error: cannot look up '<nixpkgs/nixos/lib/make-system-tarball.nix>' in pure evaluation mode (use '--impure' to override)
            #
            #       at /nix/store/0b099b46lb9dmhwzyc2zgjk8lp8d9rfq-source/kexec/kexec.nix:42:49:
            #
            #           41|   '';
            #           42|   system.build.kexec_tarball = pkgs.callPackage <nixpkgs/nixos/lib/make-system-tarball.nix> {
            #             |                                                 ^
            #           43|     storeContents = [
            "kexec"
            "kexec-bundle"
          ];

          excludeNixpkgs = [
            # error: path '/nix/store/0bsydzh62cn1by07j5cjy28crbnbc5wz-google-guest-configs-20211116.00.drv' is not valid)
            "gce"

            # Compilation error in some prerequisite or other.
            "proxmox"
          ];

          excludeNixos = [
            # error: getting status of '/nix/store/<...>/nixos/modules/virtualisation/kubevirt.nix': No such file or directory
            "kubevirt"

            # error: getting status of '/nix/store/<...>/nixos/modules/virtualisation/proxmox-lxc.nix': No such file or directory
            "proxmox-lxc"
          ];

          aarch64Only = [ "sd-aarch64" "sd-aarch64-installer" ];

          baseModules = builtins.removeAttrs self.nixosModules excludeCommon;
          nixpkgsModules = builtins.removeAttrs baseModules excludeNixpkgs;
          nixosModules = builtins.removeAttrs baseModules excludeNixos;

          matrix = {
            "x86_64-linux" = {
              "nixpkgs" = builtins.removeAttrs nixpkgsModules aarch64Only;
              "nixos" = builtins.removeAttrs nixosModules aarch64Only;
            };

            "aarch64-linux" = {
              "nixpkgs" = nixlib.lib.getAttrs aarch64Only nixpkgsModules;
              "nixos" = nixlib.lib.getAttrs aarch64Only nixosModules;
            };
          };
        in system: id: matrix.${system}.${id};
      in
      forCheckSystems (system: let
        checksForNixpkgs' = checksForNixpkgs system;

        nixpkgsChecks = checksForNixpkgs' {
          input = nixpkgs;
          id = "nixpkgs";
        };

        nixosChecks = checksForNixpkgs' {
          input = nixos;
          id = "nixos";
        };
      in nixpkgsChecks // nixosChecks);
    }
  );
}
