{ stdenv, fetchurl, fetchFromGitHub
, cmake, autoreconfHook, libtool
, sqlite, bison, flex, boost, python, libunwind, papi, libmonitor, libiberty
, cbtf, cbtf-argonavis, cbtf-krell
, libelf, libdwarf, binutils, tbb, openmpi}:

stdenv.mkDerivation rec{
  name = "OpenSpeedShop-${version}";
  version = rev;
  rev = "5196b239aedfce2b93333112fc68797e87baac04";

  src = fetchFromGitHub {
    owner = "OpenSpeedShop";
    repo = "openspeedshop";
    rev = "${version}";
    sha256 = "0lcp4pryn9m3gsi8ihfsi2gma98jizs70jplsb8rlq0v8fyx4hf2";
  };


  # src = fetchurl {
  #   name = "openspeedshop-release-2.4.tar.gz";
  #   url = "https://sourceforge.net/projects/openss/files/openss/openspeedshop-2.4/openspeedshop-release-2.4.tar.gz/download";
  #   sha256 = "1yg3jvq7i1rm1n8n0phy0gfx8ccy75nqmfnv3whjj9smjg4z4yzi";
  # };

  nativeBuildInputs = [
    cmake
    libtool
    bison
    flex
  ];
  CFLAGS ="-DNDEBUG -DHAVE_INTTYPES_H";
  buildInputs = [
    sqlite
    boost
    python
    libunwind
    papi
    libmonitor
    libiberty
    cbtf
    cbtf-argonavis
    cbtf-krell

    libelf
    libdwarf
    binutils
    tbb
    openmpi
  ];

  enableParallelBuilding = false;

}

