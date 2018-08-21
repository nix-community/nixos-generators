{ lib, ... }:
let

  elvis-jerrico-cross-nixos-aarch64  = builtins.fetchGit {
    url = https://github.com/ElvishJerricco/cross-nixos-aarch64.git;
    rev = "c6c93a514344996a48809f728009d9e01f96f6a5";
  };

in {
  imports = [
    <nixcfg>
    "${elvis-jerrico-cross-nixos-aarch64}/sd-image-aarch64.nix"
  ];

  security.polkit.enable = false;
  services.udisks2.enable = false;

  programs.command-not-found.enable = false;

  system.boot.loader.kernelFile = lib.mkForce "Image";

  # installation-device.nix forces this on. But it currently won't
  # cross build due to w3m
  services.nixosManual.enable = lib.mkOverride 0 false;

  # installation-device.nix turns this off.
  systemd.services.sshd.wantedBy = lib.mkOverride 0 ["multi-user.target"];


  # todo : change !!!
  nixpkgs.crossSystem = lib.systems.examples.raspberryPi;

  nix.checkConfig = false;

  networking.wireless.enable = lib.mkForce false;

  nixpkgs.config.allowUnsupportedSystem = true;

  system.stateVersion = "18.03";

}

