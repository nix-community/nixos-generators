{ config, lib, pkgs, ... }:
{
  services.sshd.enable = true;
  services.nginx.enable = true;

  users.users.root =  {
    password = "password"; # Please change
  };

  users.users.root.openssh.authorizedKeys.keys = [
    # Put your pubkey here
  ];
}
