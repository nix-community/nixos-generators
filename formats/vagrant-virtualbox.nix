{ modulesPath, ... }:
{
  imports = [
    "${toString modulesPath}/virtualisation/vagrant-virtualbox-image.nix"
  ];

  contents = files;
  formatAttr = "vagrantVirtualbox";
}
