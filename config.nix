{ config, lib, pkgs, ... }:
{
  services.sshd.enable = true;
  services.nginx.enable = true;
}
