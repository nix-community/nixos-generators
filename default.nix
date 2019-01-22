{ pkgs ? import <nixpkgs> {} }:

with pkgs;
stdenv.mkDerivation {
  name = "nixos-generators";
  src = ./.;
  nativeBuildInputs = [ makeWrapper ];
  installFlags = [ "PREFIX=$(out)" ];
  postFixup = ''
    wrapProgram $out/bin/nixos-generate \
      --prefix PATH : ${lib.makeBinPath [ jq coreutils findutils nix ] }
  '';
}
