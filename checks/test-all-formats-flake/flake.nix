/*
Tests using the all-formats module through a flake.
- Tests if foramts can be customized.
- Tests if new foramts can be added
*/
{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = {
    self,
    nixpkgs,
    nixos-generators,
    ...
  }: {
    nixosModules.my-machine = {config, ...}: {
      imports = [
        nixos-generators.nixosModules.all-formats
      ];

      nixpkgs.hostPlatform = "x86_64-linux";

      # customize an existing format
      formatConfigs.vmware = {config, ...}: {
        services.openssh.enable = false;
      };

      # define a new format
      formatConfigs.my-custom-format = {
        config,
        modulesPath,
        ...
      }: {
        imports = ["${toString modulesPath}/installer/cd-dvd/installation-cd-base.nix"];
        formatAttr = "isoImage";
        fileExtension = ".iso";
        networking.wireless.networks = {
          # ...
        };
      };
    };

    nixosConfigurations.my-machine = nixpkgs.lib.nixosSystem {
      modules = [self.nixosModules.my-machine];
    };

    checks.x86_64-linux = {
      test-flake_vmware =
        self.nixosConfigurations.my-machine.config.formats.vmware;
      test-flake_my-custom-format =
        self.nixosConfigurations.my-machine.config.formats.my-custom-format;
    };
  };
}
