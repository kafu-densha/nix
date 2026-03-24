{ pkgs, lib, ... }:

{
  imports = [
    ../../home/default.nix
  ];
  
  home.sessionPath = [
    "/opt/homebrew/bin"
    "/opt/homebrew/sbin"
    "/usr/local/bin"
    "/Users/elenah/scripts"
    "/Applications/Docker.app/Contents/Resources/bin/"
  ];
  
  home.shellAliases = {
    tailscale = "/Applications/Tailscale.app/Contents/MacOS/Tailscale";
    python = "python3";
    newrepo = "gh repo create --private --source=. --remote=origin";
    bu = "brew update && brew upgrade";
    qr = "kiro-cli restart";
    switch = "cd ~/.nixos && git pull && nh darwin switch && cd -";
  };
}
