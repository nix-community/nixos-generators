{
  stdenv,
  makeWrapper,
  jq,
  coreutils,
  findutils,
  lib,
}:
stdenv.mkDerivation {
  name = "nixos-generate";
  src = ./.;
  meta.description = "Collection of image builders";
  nativeBuildInputs = [makeWrapper];
  installFlags = ["PREFIX=$(out)"];
  postFixup = ''
    wrapProgram $out/bin/nixos-generate \
      --prefix PATH : ${lib.makeBinPath [jq coreutils findutils]}
  '';
}
