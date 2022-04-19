{ lib
, gcc8Stdenv
, fetchFromGitHub
, cmake
, pkg-config
, radare2
, pugixml
}:

gcc8Stdenv.mkDerivation rec {
  pname = "r2ghidra";
  version = "5.6.2";

  src = fetchFromGitHub {
    owner = "radareorg";
    repo = "r2ghidra";
    rev = version;
    sha256 = "sha256-VAON7T20dO1DW+0fS5zPjkQaSVOLcCvU35SvgCV1JV8=";
  };

  postUnpack =
    let
      ghidra-native = (fetchFromGitHub {
        owner = "radareorg";
        repo = "ghidra-native";
        rev = "e45b661d59978b371e30a5540064a31e6ea647f0";
        sha256 = "sha256-nS4InqEDfOJ3lsDcPOQEJE83RIY9QVBoOvLp1GI1KAk=";
      }); in
    ''
      cp -R ${ghidra-native} source/ghidra-native
      chmod +w -R source/ghidra-native
      make -C source/ghidra-native patch
    '';

  cmakeFlags = [ "-DUSE_SYSTEM_PUGIXML=ON" ];

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    radare2
    pugixml
  ];

  meta = with lib; {
    description = "Ghidra decompiler plugin for radare2";
    homepage = "https://github.com/radareorg/r2ghidra";
    license = licenses.lgpl3;
    maintainers = with maintainers; [ ];
    platforms = platforms.unix;
  };
}
