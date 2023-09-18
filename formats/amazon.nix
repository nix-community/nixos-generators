{modulesPath, ...}: {
  imports = [
    "${toString modulesPath}/../maintainers/scripts/ec2/amazon-image.nix"
  ];

  formatAttr = "amazonImage";
  fileExtension = ".vhd";
}
