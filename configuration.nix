{ config, lib, ... }:
{
  services.sshd.enable = true;
  services.nginx.enable = true;

  networking.firewall.allowedTCPPorts = [ 80 ];

  system.stateVersion = config.system.nixos.release;

  users.users.root.password = "nixos";
  services.openssh.settings.PermitRootLogin = lib.mkOverride 999 "yes";
  services.getty.autologinUser = lib.mkOverride 999 "root";
}
