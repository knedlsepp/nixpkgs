{ stdenv, fetchFromGitHub
, cmake, boost, mrnet, cbtf
}:
stdenv.mkDerivation rec{
  name = "cbtf-krell-${version}";
  version = rev;
  rev = "342257693b1176863a1087fb9a23025e1b8f714a";

  src = fetchFromGitHub {
    owner = "OpenSpeedShop";
    repo = "cbtf-krell";
    rev = "${version}";
    sha256 = "1191ari4xszb27lzypvxxh2mxkbs1bxrwlg9a17z9n224h0rfacv";
  };

  nativeBuildInputs = [
    cmake
  ];
  buildInputs = [
    boost
    mrnet
    cbtf
  ];
  cmakeFlags = [
    "-DCMAKE_PREFIX_PATH=${cbtf}"
    "-DCBTF_DIR=${cbtf}"
    "-DCMAKE_VERBOSE_MAKEFILE:BOOL=ON"
  ];
  enableParallelBuilding = false;

}

