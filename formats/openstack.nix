{ modulesPath, ... }:
{
  imports = [
    "${toString modulesPath}/../maintainers/scripts/openstack/nova-image.nix"
  ];

  formatAttr = "novaImage";
}
