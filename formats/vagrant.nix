{ pkgs, config, lib, ... }:
{
  imports = [
    ./virtualbox.nix
    ../profiles/vagrant.nix
  ];

  config = {
    formatAttr = lib.mkForce "vagrantImage";
    system.build.vagrantImage =
      let
        metadata = {
          provider = "virtualbox";
        };
      in
      pkgs.runCommand "vagrant-image" {} ''
        cp "${config.system.build.virtualBoxOVA}/${config.virtualbox.vmFileName}" image.ova

        cat <<'EOF' > metadata.json
        ${builtins.toJSON metadata}
        EOF

        tar czf vagrantbox.tar.gz *

        mkdir $out

        cp vagrantbox.tar.gz $out/vagrant.box
      '';
  };

}
