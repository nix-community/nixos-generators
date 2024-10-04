{
  modulesPath,
  specialArgs,
  ...
}: {
  imports = [
    "${toString modulesPath}/virtualisation/proxmox-image.nix"
  ];

  proxmox = {
    qemuConf = {
      diskSize = specialArgs.diskSize or "auto";

      # Configuration for the default virtio disk. It can be used as a cue for PVE to autodetect the target storage.
      # This parameter is required by PVE even if it isn't used.
      virtio0 = specialArgs.virtio0 or "local-lvm:vm-9999-disk-0";
    };
    cloudInit = {
      enable = specialArgs.cloudInitEnable or true;
      defaultStorage = specialArgs.cloudInitDefaultStorage or "local-lvm";
      device = specialArgs.cloudInitDevice or "ide2";
    };
  };

  formatAttr = "VMA";
  fileExtension = ".vma.zst";
}
