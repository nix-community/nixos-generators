{ modulesPath, ... }:
{
  imports = [
    "${toString modulesPath}/virtualisation/qemu-vm.nix"
  ];

  formatAttr = "vm";
}
