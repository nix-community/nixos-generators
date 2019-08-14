{ config, lib, pkgs, ... }:
{
  services.sshd.enable = true;
  services.nginx.enable = true;

  networking.firewall.allowedTCPPorts = [ 80 ];
  
  users.users.root.password = "nixos";
  services.openssh.permitRootLogin = lib.mkDefault "yes";
  services.mingetty.autologinUser = lib.mkDefault "root";
}
