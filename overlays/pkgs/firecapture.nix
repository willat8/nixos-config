{ lib
, stdenv
, fetchurl
, autoPatchelfHook
, makeWrapper
, makeDesktopItem
, copyDesktopItems
, dpkg

, zlib
, xorg
, freetype
, gcc-unwrapped
, libusb1
, alsa-lib
, fontconfig
}:

stdenv.mkDerivation {
  pname = "firecapture";
  version = "2.7.10";

  src = fetchurl {
    url = "http://www.firecapture.de/download.php?file=FireCapture_v2.7.deb";
    name = "FireCapture_v2.7.10.deb";
    sha256 = "sha256-i6r4nO3rQVAEpnm1L9t/2KT3Q/qmH7Zk53BxJKMjd8s=";
    # Go to http://www.firecapture.de/download.php?file=FireCapture_v2.7.deb
    # to find the current question and cookie
    curlOpts = "-d password=4 --cookie PHPSESSID=37cc85244964e2ec353e38bc6cdc35a0";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
    copyDesktopItems
    dpkg
  ];

  buildInputs = [
    zlib
    xorg.libXext
    xorg.libX11
    xorg.libXrender
    xorg.libXtst
    xorg.libXi
    freetype
    gcc-unwrapped
    libusb1
    alsa-lib
  ];

  desktopItems = [
    (makeDesktopItem {
      name = "FireCapture v2.7";
      desktopName = "FireCapture v2.7";
      comment = "FireCapture planetary capture tool";
      # This will result in // at the root of the path, but it's needed to pass validation
      icon = "/@out@/icon.png";
      exec = "/@out@/start.sh";
      path = "/@out@";
      # Terminal seems to want only specific terminal emulators. More at https://gitlab.gnome.org/GNOME/glib/-/issues/338
      #terminal = true;
      categories = [ "Utility" "Development" ];
    })
  ];

  unpackCmd = "dpkg -x $curSrc .";

  setSourceRoot = ''
    sourceRoot=$(echo opt/*)
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -r * $out

    # Set nonreparenting to fix blank window, on first run set up ~/.config/FireCapture to avoid logging to outPath
    wrapProgram $out/start.sh --set _JAVA_AWT_WM_NONREPARENTING 1 --run "
      export _JAVA_OPTIONS=-Duser.home=\$HOME/.config &&
      mkdir -p ~/.config/FireCapture &&
      cp --no-preserve=mode -rn $out/profiles ~/.config/FireCapture &&
      cp --no-preserve=mode -n $out/FireCapture.ini ~/.config/FireCapture
    "

    # To fix the dependencies of AVIWriter_x64.so
    ln -sfv avi_writer_x64.so $out/avi_writer.so.1

    # Has to be done here after autoPatchelfHook removes the RPATH
    # fontconfig isn't linked but is dlopened at runtime
    function finalRPathFixups {
      patchelf --add-rpath ${fontconfig.lib}/lib $out/jre/lib/libawt_xawt.so
    }
    postFixupHooks+=(finalRPathFixups)

    # Has to be done here after copyDesktopItems creates the file
    function desktopItemSub {
      substituteAllInPlace $out/share/applications/"FireCapture v2.7.desktop"
    }
    postInstallHooks+=(desktopItemSub)

    runHook postInstall
  '';
}
