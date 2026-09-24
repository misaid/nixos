# Your exact custom SilentSDDM 1.3.4 "lana" theme, packaged verbatim.
#
# Base is stock v1.3.4 QML (pinned flake=false input `silentSDDM`); your
# deltas from /usr/share/sddm/themes/SilentSDDM-1.3.4 are overlaid:
#   assets/lana.conf  (custom config: lock=custom lana.mp4, login=stock rei.mp4)
#   assets/lana.mp4   (custom video)
#   assets/lana.png   (custom animated-background placeholder)
#
# SDDM is only the session picker here — the theme's own LockScreen is
# switched off (same append-override mechanism upstream's package uses)
# so GNOME owns screen locking. Set directly via
# services.displayManager.sddm.theme (a plain theme name, no preset enum).
{ pkgs, inputs, ... }:

let
  themeName = "silent-lana";

  silentLana = pkgs.stdenvNoCC.mkDerivation {
    pname = themeName;
    version = "1.3.4-custom";
    src = inputs.silentSDDM;
    dontBuild = true;
    installPhase = ''
      runHook preInstall
      themeDir=$out/share/sddm/themes/${themeName}
      mkdir -p $themeDir
      cp -r $src/* $themeDir/
      chmod -R +w $themeDir
      cp ${./assets/lana.mp4} $themeDir/backgrounds/lana.mp4
      cp ${./assets/lana.png} $themeDir/backgrounds/lana.png
      cp ${./assets/lana.conf} $themeDir/configs/lana.conf
      substituteInPlace $themeDir/metadata.desktop \
        --replace 'ConfigFile=configs/default.conf' 'ConfigFile=configs/lana.conf'
      # SDDM = session picker only; GNOME locker handles locking.
      cat >> $themeDir/configs/lana.conf <<EOF

      [LockScreen]
      display = false
      EOF
      runHook postInstall
    '';
  };
in
{
  environment.systemPackages = [ silentLana ];

  services.displayManager.sddm = {
    enable = true;
    # X11 greeter (NVIDIA-safe); the launched sessions are unaffected.
    wayland.enable = false;
    theme = themeName;
    # Video backgrounds + virtual keyboard need these at greeter runtime.
    extraPackages = with pkgs.kdePackages; [
      qtmultimedia
      qtsvg
      qtvirtualkeyboard
      qtimageformats
    ];
    settings.General = {
      GreeterEnvironment = "QML2_IMPORT_PATH=${silentLana}/share/sddm/themes/${themeName}/components/,QT_IM_MODULE=qtvirtualkeyboard";
      InputMethod = "qtvirtualkeyboard";
    };
  };
}
