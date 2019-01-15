{ modulesPath, ... }:
{
  imports = [
    "${toString modulesPath}/virtualisation/google-compute-image.nix"
    <nixcfg>
  ];
}
