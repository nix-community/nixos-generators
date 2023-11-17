{
  config,
  lib,
  pkgs,
  ...
}: {
  services.sshd.enable = true;
  services.nginx.enable = true;

  networking.firewall.allowedTCPPorts = [80];

  system.stateVersion = lib.version;

  users.users.root.password = "nixos";
  services.openssh.settings.PermitRootLogin = lib.mkDefault "yes";
  services.getty.autologinUser = lib.mkDefault "root";
}
