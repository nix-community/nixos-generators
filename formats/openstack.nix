{
  modulesPath,
  ...
}:
{
  imports = [
    "${toString modulesPath}/../maintainers/scripts/openstack/openstack-image.nix"
  ];
  formatAttr = "openstackImage";
  fileExtension = ".qcow2";
}
