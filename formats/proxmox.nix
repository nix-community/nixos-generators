{
  modulesPath,
  specialArgs,
  config,
  ...
}: {
  imports = [
    "${toString modulesPath}/virtualisation/proxmox-image.nix"
  ];

  proxmox = {
    qemuConf.diskSize = specialArgs.diskSize or config.proxmox.qemuConf.diskSize.default;
    cloudInit = {
      enable = specialArgs.enableCloudInit or config.proxmox.cloudInit.enableCloudInit.default;
      defaultStorage = specialArgs.defaultStorage or config.proxmox.cloudInit.defaultStorage.default;
      device = specialArgs.device or config.proxmox.cloudInit.device.default;
    };
  };

  formatAttr = "VMA";
  fileExtension = ".vma.zst";
}
