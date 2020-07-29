{ modulesPath, ... }:
{
  imports = [
    ./vm.nix
  ];

  virtualisation.useBootLoader = true;
}
