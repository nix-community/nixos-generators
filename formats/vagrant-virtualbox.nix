{ modulesPath, ... }:
{
  imports = [
    "${toString modulesPath}/virtualisation/vagrant-virtualbox-image.nix"
  ];

  formatAttr = "vagrantVirtualbox";
}
