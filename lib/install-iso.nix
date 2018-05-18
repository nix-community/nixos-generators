{ config, lib , ... }:
{
  imports = [
    <nixpkgs/nixos/modules/installer/cd-dvd/installation-cd-base.nix>
    <nixcfg>
  ];

  # for installer
  isoImage.isoName = "nixos.iso";

  # override installation-cd-base and enable wpa and sshd start at boot
  systemd.services.wpa_supplicant.wantedBy = lib.mkForce [ "multi-user.target" ];
  systemd.services.sshd.wantedBy = lib.mkForce [ "multi-user.target" ];

}
