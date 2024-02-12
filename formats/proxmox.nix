{
  modulesPath,
  specialArgs,
  ...
}: {
  imports = [
    "${toString modulesPath}/virtualisation/proxmox-image.nix"
  ];

  proxmox.qemuConf.diskSize = specialArgs.diskSize or "auto";

  formatAttr = "VMA";
  fileExtension = ".vma.zst";
}
