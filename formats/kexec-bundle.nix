{lib, ...}: {
  imports = [./kexec.nix];

  formatAttr = lib.mkForce "kexec_bundle";
  fileExtension = lib.mkForce "-kexec_bundle";
}
