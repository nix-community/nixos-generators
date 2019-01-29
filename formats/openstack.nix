{ modulesPath, ... }:
{
  imports = [
    "${modulesPath}/../maintainers/scripts/openstack/nova-image.nix"
  ];

  formatAttr = "novaImage";
}
