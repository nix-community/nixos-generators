{ ... }:
{
  imports = [
    <nixpkgs/nixos/maintainers/scripts/openstack/nova-image.nix>
  ];

  formatAttr = "novaImage";
}
