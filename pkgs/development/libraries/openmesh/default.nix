{ mkDerivation, lib, fetchurl, cmake, qtbase }:

mkDerivation rec {
  version = "8.0";
  pname = "openmesh";

  src = fetchurl {
    url = "https://www.openmesh.org/media/Releases/${version}/OpenMesh-${version}.tar.gz";
    sha256 = "10pcaz85044kc8fng7fzr4rgsjr8db4vai8r2xxs7jna4r0d8x49";
  };

  cmakeFlags = [
    "-DOpenGL_GL_PREFERENCE=GLVND"
  ];

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    qtbase
  ];

  meta = with lib; {
    description = "A generic and efficient polygon mesh data structure";
    homepage = https://www.openmesh.org/;
    license = with licenses; [ bsd3 ];
    platforms = platforms.all;
    maintainers = [ ];
  };
}
