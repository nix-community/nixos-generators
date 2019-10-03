{ config, lib, pkgs, ... }:
let

  # cat ~/.ssh/id_rsa.pub
  publicSshKey = "";

  # remote-install-get-hiddenReceiver
  hiddenReceiver = "";

in {

  imports = [
    { # system setup
      networking.hostName = "liveos";

      users.extraUsers = {
        root = {
          password = "lolhack";
          openssh.authorizedKeys.keys = [
            publicSshKey
          ];
        };
      };

      environment.extraInit = ''
        EDITOR=vim
      '';
    }
    { # installed packages
      nixpkgs.config.allowUnfree = true;
      environment.systemPackages = with pkgs; [
      #style
        most
        rxvt_unicode.terminfo

      #monitoring tools
        htop
        iotop

      #network
        iptables
        iftop
        nmap

      #stuff for dl
        aria2

      #neat utils
        pciutils
        psmisc
        tmux
        usbutils
        git

      #unpack stuff
        p7zip
        unzip
        unrar

      #data recovery
        ddrescue
        ntfs3g
        dosfstools
      ];
    }
    { # bash configuration
      programs.bash = {
        enableCompletion = true;
        interactiveShellInit = ''
          HISTCONTROL='erasedups:ignorespace'
          HISTSIZE=65536
          HISTFILESIZE=$HISTSIZE

          shopt -s checkhash
          shopt -s histappend histreedit histverify
          shopt -s no_empty_cmd_completion
          complete -d cd
        '';
        promptInit = ''
          if test $UID = 0; then
            PS1='\[\033[1;31m\]\w\[\033[0m\] '
            PROMPT_COMMAND='echo -ne "\033]0;$$ $USER@$PWD\007"'
          elif test $UID = 1337; then
            PS1='\[\033[1;32m\]\w\[\033[0m\] '
            PROMPT_COMMAND='echo -ne "\033]0;$$ $PWD\007"'
          else
            PS1='\[\033[1;33m\]\u@\w\[\033[0m\] '
            PROMPT_COMMAND='echo -ne "\033]0;$$ $USER@$PWD\007"'
          fi
          if test -n "$SSH_CLIENT"; then
            PS1='\[\033[35m\]\h'" $PS1"
            PROMPT_COMMAND='echo -ne "\033]0;$$ $HOSTNAME $USER@$PWD\007"'
          fi
        '';
      };
    }
    { # ssh configuration
      services.openssh.enable = true;
      services.openssh.passwordAuthentication = false;
      systemd.services.sshd.wantedBy = lib.mkForce [ "multi-user.target" ];
    }
    { # network configuration
      networking.networkmanager.enable = true;
      networking.wireless.enable = lib.mkForce false;
    }
    { # hidden ssh announce
      config = let
        torDirectory = "/var/lib/tor";
        hiddenServiceDir = torDirectory + "/liveos";
      in {
        services.tor = {
          enable = true;
          client.enable = true;
          extraConfig = ''
            HiddenServiceDir ${hiddenServiceDir}
            HiddenServicePort 22 127.0.0.1:22
          '';
        };
        systemd.services.hidden-ssh-announce = {
          description = "irc announce hidden ssh";
          after = [ "tor.service" "network-online.target" ];
          wants = [ "tor.service" ];
          wantedBy = [ "multi-user.target" ];
          serviceConfig = {
            ExecStart = pkgs.writers.writeDash "irc-announce-ssh" ''
              set -efu
              until test -e ${hiddenServiceDir}/hostname; do
                echo "still waiting for ${hiddenServiceDir}/hostname"
                sleep 1
              done
              until ${pkgs.tor}/bin/torify ${pkgs.netcat-openbsd}/bin/nc -z ${hiddenReceiver} 1337; do sleep 1; done && \
                echo "torify ssh root@$(cat ${hiddenServiceDir}/hostname) -i ~/.ssh/id_rsa" | ${pkgs.tor}/bin/torify ${pkgs.nmap}/bin/ncat ${hiddenReceiver} 1337
            '';
            PrivateTmp = "true";
            User = "tor";
            Type = "oneshot";
          };
        };
      };
    }
  ];
}
