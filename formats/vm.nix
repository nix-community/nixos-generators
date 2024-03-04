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

  virtualisation.diskSize = lib.mkIf (diskSize != "auto") (lib.strings.toIntBase10 diskSize);

  formatAttr = "vm";
}
