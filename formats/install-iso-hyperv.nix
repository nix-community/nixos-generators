{ config, lib, modulesPath, ... }:
{
  imports = [
    "${toString modulesPath}/installer/cd-dvd/installation-cd-base.nix"
  ];

  # override installation-cd-base and enable wpa and sshd start at boot
  systemd.services.sshd.wantedBy = lib.mkForce [ "multi-user.target" ];
  virtualisation.hypervGuest.enable = true;

  formatAttr = "isoImage";
}
