{
  modulesPath,
  specialArgs,
  lib,
  ...
}: let
  diskSize = specialArgs.diskSize or "auto";
in {
  imports = [
    "${toString modulesPath}/virtualisation/vmware-image.nix"
  ];

  vmware.baseImageSize =
    if diskSize == "auto"
    then "auto"
    else lib.strings.toIntBase10 diskSize;

  formatAttr = "vmwareImage";
  fileExtension = ".vmdk";
}
