{ stdenv, fetchurl
, autoPatchelfHook
, curl, ffmpeg, libjpeg_original, libuuid, libv4l, openh264, pam, rpmextract, qt5, SDL, xorg
}:
 let
   # Sky is linked to the libjpeg 8 version and checks for the version number in the code.
   libjpeg_original_fix = libjpeg_original.overrideAttrs (oldAttrs: {
    src = fetchurl{
      url = https://www.ijg.org/files/jpegsrc.v8d.tar.gz;
      sha256 = "1cz0dy05mgxqdgjf52p54yxpyy95rgl30cnazdrfmw7hfca9n0h0";
    };
  });
in
stdenv.mkDerivation rec {
  version_major = "2.1.7369";
  version_minor = "1";
  version = version_major + "." + version_minor;
  name = "sky-${version}";
  src = fetchurl {
    url = "https://tel.red/repos/opensuse/42.3/x86_64/sky-${version_major}-${version_minor}.osu42.3.x86_64.rpm";
    sha256 = "0wdh7ixj5y5wldj3i5j4y56c6a91jcf0gnzpz198v9plkg6yl0p7";
  };
  nativeBuildInputs = [ autoPatchelfHook rpmextract ];
  unpackCmd = "rpmextract $curSrc";
  buildInputs = [
    curl
    ffmpeg
    libjpeg_original_fix
    libv4l
    pam
    qt5.qtbase
    SDL
    stdenv.cc.cc
    xorg.libX11
    xorg.libXdamage
    xorg.libxkbfile
    xorg.libXmu
    xorg.libXScrnSaver
    xorg.libXtst
    xorg.libXv
  ];
  installPhase = ''
    mkdir -p $out
    cp -r * $out
    mkdir -p $out/bin
    ln -sf  $out/lib*/sky/sky $out/bin/
    ln -sf $out/lib*/sky/sky_sender $out/bin/
  '';
  preFixup = ''
    find $out
    substituteInPlace $out/share/applications/sky.desktop \
          --replace "Exec=/usr/bin/sky" "Exec=$out/bin/sky" \
          --replace "Path=/usr/lib/sky" ""
  '';
  dontStrip = true;
  meta = with stdenv.lib; {
    description = "Skype for business";
    longDescription = ''
      Lync & Skype for business on linux
    '';
    homepage = https://tel.red/;
    license = licenses.unfree;
    maintainers = [ maintainers.Scriptkiddi ];
    platforms = [ "x86_64-linux" ];
  };
}

