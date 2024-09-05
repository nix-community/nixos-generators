{
  lib,
  modulesPath,
  ...
}: {
  imports = [
    "${toString modulesPath}/virtualisation/qemu-vm.nix"
  ];
  virtualisation.diskSize = lib.mkDefault (2 * 1024);
  formatAttr = "vm";
}
