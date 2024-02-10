{
  modulesPath,
  specialArgs,
  lib,
  ...
}: let
  diskSize = specialArgs.diskSize or "auto";
in {
  imports = [
    "${toString modulesPath}/virtualisation/hyperv-image.nix"
  ];

  hyperv.baseImageSize =
    if diskSize == "auto" then "auto"
    else lib.strings.toIntBase10 diskSize;

  formatAttr = "hypervImage";
  fileExtension = ".vhdx";
}
