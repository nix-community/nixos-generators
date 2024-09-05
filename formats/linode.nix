{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  imports = [
    "${toString modulesPath}/virtualisation/linode-image.nix"
  ];

  formatAttr = "linodeImage";
  fileExtension = ".img.gz";

  system.build.linodeImage = import "${toString modulesPath}/../lib/make-disk-image.nix" {
    inherit lib config pkgs;
    partitionTableType = "none";
    format = "raw";
    postVM = ''
      ${pkgs.pigz}/bin/pigz -9 $out/nixos.img
    '';
  };

  # Enable LISH and Linode booting w/ GRUB
  boot = {
    growPartition = true;

    loader = {
      grub = {
        fsIdentifier = "label";

        # Link /boot/grub2 to /boot/grub:
        extraInstallCommands = ''
          ${pkgs.coreutils}/bin/ln -fs /boot/grub /boot/grub2
        '';

        # Remove GRUB splash image:
        splashImage = null;
      };
    };
  };

  # Hardware option detected by nixos-generate-config:
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # Install diagnostic tools for Linode support:
  environment.systemPackages = with pkgs; [
    linode-cli
  ];

  networking = {
    enableIPv6 = true;
    interfaces.eth0 = {
      tempAddress = "disabled";
      useDHCP = true;
    };
  };

  services.qemuGuest.enable = true;
}
