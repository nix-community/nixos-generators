{ ... }:
{
  imports = [
    <nixpkgs/nixos/modules/virtualisation/virtualbox-image.nix>
  ];

  formatAttr = "virtualBoxOVA";
}
