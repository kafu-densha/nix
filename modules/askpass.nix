{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.ssh-askpass;

  version = "v0.1.0";
  askpass = pkgs.stdenv.mkDerivation {
    pname = "ssh-askpass-zigtk";
    inherit version;

    src = pkgs.fetchFromGitHub {
      owner = "mrusme";
      repo = "ssh-askpass-zigtk";
      tag = version;
      hash = "sha256-2NoM3TLSTJ4Gf+C+qGvq/Y2q9Va+wmmcM9FE9xeunWE=";
    };

    nativeBuildInputs = with pkgs; [
      zig_0_16.hook
      wrapGAppsHook4
      pkg-config
    ];

    buildInputs = with pkgs; [
      gtk4
    ];

    meta.mainProgram = "ssh-askpass-zigtk";
  };
in
{
  options.ssh-askpass = {
    enable = lib.mkEnableOption "custom ssh askpass with gtk4 support";
    package = lib.mkOption {
      type = lib.types.package;
      default = askpass;
    };
  };

  config = lib.mkIf cfg.enable {
    programs.ssh.askPassword = lib.mkForce (lib.getExe askpass);
  };
}
