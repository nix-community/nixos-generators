{
  modulesPath,
  lib,
  ...
}:
if lib.pathExists "${toString modulesPath}/../maintainers/scripts/openstack/nova-image.nix"
then {
  imports = [
    "${toString modulesPath}/../maintainers/scripts/openstack/nova-image.nix"
  ];

  formatAttr = "novaImage";
}
else {
  imports = [
    "${toString modulesPath}/../maintainers/scripts/openstack/openstack-image.nix"
  ];
  formatAttr = "openstackImage";
}
