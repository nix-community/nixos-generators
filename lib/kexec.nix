{ lib, ... }: let

  clever-tests = builtins.fetchGit {
    url = https://github.com/cleverca22/nix-tests;
    rev = "4761ec62c4056f2b1df4d468a1e129b808734221"; #master on 2018-05-20
  };
in {
  imports = [
    <nixpkgs/nixos/modules/installer/netboot/netboot-minimal.nix>
    <nixcfg>
    "${clever-tests}/kexec/autoreboot.nix"
    "${clever-tests}/kexec/kexec.nix"
    "${clever-tests}/kexec/justdoit.nix"
  ];
  boot.loader.grub.enable = false;
  boot.kernelParams = [
    "console=ttyS0,115200"          # allows certain forms of remote access, if the hardware is setup right
    "panic=30" "boot.panic_on_fail" # reboot the machine upon fatal boot issues
  ];
  systemd.services.sshd.wantedBy = lib.mkForce [ "multi-user.target" ];
  networking.hostName = lib.mkDefault "kexec";
}

