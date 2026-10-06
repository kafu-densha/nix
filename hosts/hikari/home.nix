{
  ...
}:

{
  imports = [
    ../../home/default.nix
    ../../home/gui.nix
  ];

  # gnome theme
  gtk = {
    enable = true;
    colorScheme = "dark";
  };
}
