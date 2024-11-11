{
  lib,
  ...
}: {
  imports = [
    ./install-iso.nix
  ];

  systemd.services.wpa_supplicant.wantedBy = lib.mkOverride 40 [];
  virtualisation.hypervGuest.enable = true;
}
