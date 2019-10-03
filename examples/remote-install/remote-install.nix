# installs scripts and tor to provide an announcement service for nixos-remote installation.
{
  services.tor = {
    enable = true;
    client.enable = true;
    hiddenServices.liveos.map = [
      { port = 1337; }
    ];
  };

  environment.systemPackages = [
    (pkgs.writeShellScriptBin "remote-install-start-service" ''
      echo "starting announcment server to receive remote-install iso onion id"
      ${pkgs.nmap}/bin/ncat -k -l -p 1337
    '')
    (pkgs.writeShellScriptBin "remote-install-get-hiddenReceiver" ''
      sudo cat /var/lib/tor/onion/liveos/hostname
    '')
  ];
}
