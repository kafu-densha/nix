{
  pkgs,
  lib,
  ...
}:

let
  titdb = pkgs.stdenv.mkDerivation {
    name = "trackpad-is-too-damn-big";

    src = pkgs.fetchFromGitHub {
      owner = "tascvh";
      repo = "trackpad-is-too-damn-big";
      rev = "26fcd89a8e9620be11783c34aedeff12968ae600";
      hash = "sha256-zEfME1dSLpXg7m8HSZgRsGY74wV+X6HNOa8wS30J518=";
      fetchSubmodules = true;
    };

    nativeBuildInputs = with pkgs; [
      cmake
      pkg-config
      libevdev
    ];

    installPhase = ''
      runHook preInstall

      mkdir -p $out/bin
      cp titdb $out/bin/

      runHook postInstall
    '';

    meta.mainProgram = "titdb";
  };
in
{
  systemd.services.titdb = {
    description = "trackpad-is-too-damn-big";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Restart = "always";
      ExecStart = "${lib.getExe titdb} -d /dev/input/by-path/platform-39b10c000.spi-cs-0-event-mouse";
    };
  };
}
