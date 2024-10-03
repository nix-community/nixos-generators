{
  lib,
  modulesPath,
  specialArgs,
  ...
}: {
  imports = [
    "${toString modulesPath}/virtualisation/proxmox-image.nix"
  ];

  proxmox.qemuConf = {
    diskSize = specialArgs.diskSize or "auto";
  } // (lib.optionalAttrs ((builtins.hasAttr "bootSize" specialArgs) && specialArgs.bootSize != null) {
    bootSize = "${builtins.toString specialArgs.bootSize}M";
  });

  formatAttr = "VMA";
  fileExtension = ".vma.zst";
}
