{ lib, ... }:
{
  imports = [ ./kexec.nix ];

  formatAttr = lib.mkForce "kexec_bundle";
  filename = lib.mkForce "*-kexec_bundle";
}
