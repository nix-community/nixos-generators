{ pkgs, ... }:
{
  imports = [
    ./vm.nix
  ];
  virtualisation.graphics = false;
  virtualisation.qemu.options = [
    "-serial mon:stdio"
  ];

  environment.systemPackages = [
    (pkgs.writeScriptBin "resize" ''
      old=$(stty -g)
      stty raw -echo min 0 time 5
      printf '\033[18t' > /dev/tty
      IFS=';t' read -r _ rows cols _ < /dev/tty
      stty "$old"
      stty cols "$cols" rows "$rows"
    '') # https://unix.stackexchange.com/questions/16578/resizable-serial-console-window
  ];
}
