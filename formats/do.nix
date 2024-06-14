{modulesPath, lib, ...}: {
  imports = [
    "${toString modulesPath}/virtualisation/digital-ocean-image.nix"
    {
      config.boot.loader.grub.devices = lib.mkForce [ "/dev/vda" "/dev/vdb" ];
    }
  ];

  formatAttr = "digitalOceanImage";
  fileExtension = ".qcow2.gz";
}
