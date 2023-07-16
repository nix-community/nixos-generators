{
  config,
  pkgs,
  lib,
  modulesPath,
  ...
}: {

  imports = [
    (modulesPath + "/installer/netboot/netboot-minimal.nix")
  ];

  system.build = rec {
    kexec_tarball = pkgs.callPackage "${toString modulesPath}/../lib/make-system-tarball.nix" {
      storeContents = [
        {
          object = pkgs.writeScript "kexec" ''
            kexec \
              --load ${config.system.build.toplevel}/kernel \
              --initrd ${config.system.build.toplevel}/initrd \
              --command-line "$(</proc/cmdline)"
          '';
          symlink = "/kexec_nixos";
        }
      ];
      contents = [];
    };

    kexec_tarball_self_extract_script = pkgs.writeTextFile {
      executable = true;
      name = "kexec-nixos";
      text = ''
        #!/bin/sh
        set -eu
        ARCHIVE=`awk '/^__ARCHIVE_BELOW__/ { print NR + 1; exit 0; }' $0`

        tail -n+$ARCHIVE $0 | tar xJ -C /
        /kexec_nixos

        exit 1

        __ARCHIVE_BELOW__
      '';
    };

    kexec_bundle = pkgs.runCommand "kexec_bundle" {} ''
      cat \
        ${kexec_tarball_self_extract_script} \
        ${config.system.build.kexec_tarball}/tarball/nixos-system-${config.system.build.kexec_tarball.system}.tar.xz \
        > $out
      chmod +x $out
    '';
  };

  boot.loader.grub.enable = false;
  boot.kernelParams = [
    "console=ttyS0,115200" # allows certain forms of remote access, if the hardware is setup right
    "panic=30"
    "boot.panic_on_fail" # reboot the machine upon fatal boot issues
  ];
  systemd.services.sshd.wantedBy = lib.mkForce ["multi-user.target"];
  networking.hostName = lib.mkDefault "kexec";

  formatAttr = "kexec_tarball";
  filename = "*/tarball/*.tar.xz";
}
