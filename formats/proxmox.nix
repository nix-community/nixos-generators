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
    qemuConf.diskSize = specialArgs.diskSize or "auto";
    cloudInit = {
      enable = specialArgs.enableCloudInit or true; 
      defaultStorage = specialArgs.defaultStorage or "local-lvm";
      device = specialArgs.device or  "ide2";
    };
  };

  formatAttr = "VMA";
  fileExtension = ".vma.zst";
}
