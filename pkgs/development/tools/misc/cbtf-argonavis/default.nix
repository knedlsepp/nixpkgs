{ stdenv, fetchFromGitHub
, cmake, boost, mrnet
}:
stdenv.mkDerivation rec{
  name = "cbtf-argonavis-${version}";
  version = rev;
  rev = "901bee94ac6c08bc70aae81cdfd00adc6939d97a";

  src = fetchFromGitHub {
    owner = "OpenSpeedShop";
    repo = "cbtf-argonavis";
    rev = "${version}";
    sha256 = "1191ari4xszb27lzypvxxh2mxkbs1bxrwlg9a17z9n224h0rfacv";
  };

  nativeBuildInputs = [
    cmake
  ];
  buildInputs = [
    boost
    mrnet
  ];

  enableParallelBuilding = false;

}

