{pkgs ? import <nixpkgs> {}}:
pkgs.runCommand "check-format" {} ''
  ${pkgs.alejandra}/bin/alejandra -c ${./.}
  touch $out
''
