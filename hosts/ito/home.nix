{
  ...
}:

{
  imports = [
    ../../home/default.nix
  ];

  # wallpaper engine
  services.linux-wallpaperengine = {
    enable = true;
    wallpapers = [
      {
        wallpaperId = "2530108698";
        monitor = "DP-3";
      }
    ];
  };
}
