{ ... }:
{
  imports = [
    <nixpkgs/nixos/modules/virtualisation/virtualbox-image.nix>
  ];

  targetAttr = "virtualBoxOVA";
}
