{
  modulesPath,
  specialArgs,
  lib,
  ...
}: let
  diskSize = specialArgs.diskSize or "auto";
in {
  imports = [
    "${toString modulesPath}/virtualisation/qemu-vm.nix"
  ];

  virtualisation.diskSize =
    if diskSize == "auto" then null
    else lib.strings.toIntBase10 diskSize;

  formatAttr = "vm";
}
