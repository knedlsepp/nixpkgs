{ stdenv, fetchFromGitHub
, cmake, boost, mrnet, libxml2
}:
stdenv.mkDerivation rec{
  name = "cbtf-${version}";
  version = rev;
  rev = "c508e7270c6d2c00714c199e32ebd517b8a4dd8b";

  src = fetchFromGitHub {
    owner = "OpenSpeedShop";
    repo = "cbtf";
    rev = "${version}";
    sha256 = "06i6b383gh5l7jaasp4vdxndqqaghrnhz3imr6r7m5a84046sc9g";
  };

  nativeBuildInputs = [
    cmake
  ];
  buildInputs = [
    boost
    libxml2
    mrnet
  ];
  cmakeFlags = [
    "-DRUNTIME_ONLY=TRUE"
    "-DBoost_NO_SYSTEM_PATHS=TRUE"
    "-DMRNET_DIR=${mrnet}"
  ];
  enableParallelBuilding = false;
  doCheck = true;
  checkPhase = ''
    runHook preCheck
    LD_LIBRARY_PATH=$PWD/libcbtf ./test/test
    runHook postCheck
  '';
}

