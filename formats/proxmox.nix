{
  modulesPath,
  specialArgs,
  ...
}: {
  imports = [
    "${toString modulesPath}/virtualisation/proxmox-image.nix"
  ];

  proxmox = {
    qemuConf.diskSize = specialArgs.diskSize or "auto";
    cloudInit = {
      enable = specialArgs.enableCloudInit or "auto";
      defaultStorage = specialArgs.defaultStorage or "auto";
      device = specialArgs.device "auto";
    };
  };

  formatAttr = "VMA";
  fileExtension = ".vma.zst";
}
