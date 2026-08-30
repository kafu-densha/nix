{
  ...
}:

{
  imports = [
    ./minecraft/default.nix
    ./files.nix
    ./git.nix
  ];

  elenahaug-web.enable = true;
}
