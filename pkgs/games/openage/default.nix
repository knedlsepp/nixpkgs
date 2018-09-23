{ stdenv, fetchFromGitHub, cmake, python3Packages
, pkgconfig, freetype, SDL2, SDL2_image, ftgl, epoxy, fontconfig, libopus, opusfile, libogg, libpng, harfbuzz
, opusTools, eigen3_3, qt5, nyan}:
python3Packages.buildPythonApplication rec {
  pname = "openage-unstable";
  version = "2018-09-23";
  format = "other";
  src = fetchFromGitHub {
    owner = "SFTtech";
    repo = "openage";
    rev = "082e95a1f9cb6e5418ea32eef730333083b87eb2";
    sha256 = "091gc3zmg53nsb7yhcazxdp67y0kwxn8b5fa9jya2fswb56qa4kx";
  };

  nativeBuildInputs = [
    cmake
  ];

  cmakeFlags = [
    "-DPYTHON=${python3Packages.python.interpreter}"
    "-DCMAKE_PY_INSTALL_PREFIX=${placeholder "out"}/${python3Packages.python.sitePackages}"
    # "-DGLOBAL_ASSET_DIR=${placeholder "out"}/share/openage"
    "-DGLOBAL_CONFIG_DIR=${placeholder "out"}/etc"
  ];

  postPatch = ''
    substituteInPlace openage/default_dirs.py \
      --replace 'raise Exception("macOS not really supported")' \
                'platform_table = LINUX_DIRS'
  '';

  buildInputs = [
    python3Packages.python
    python3Packages.cython
    python3Packages.pygments
    python3Packages.jinja2
    python3Packages.wrapPython
    pkgconfig
    freetype
    SDL2
    SDL2_image
    ftgl
    epoxy
    fontconfig
    libopus
    opusfile
    libogg
    libpng
    harfbuzz
    opusTools
    eigen3_3
    qt5.qtbase
    qt5.qtquickcontrols
    nyan
  ];

  propagatedBuildInputs = with python3Packages; [
    pillow
    numpy
  ];

  meta = with stdenv.lib; {
    description = "Open source clone of the Age of Empires II engine";
    homepage = https://openage.sft.mx/;
    license = licenses.gpl3Plus;
    maintainers = [ maintainers.knedlsepp ];
    platforms = platforms.all;
  };
}
