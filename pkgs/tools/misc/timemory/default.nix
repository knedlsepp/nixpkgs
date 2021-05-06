{ lib, stdenv, fetchFromGitHub, cmake, papi, gperftools }:

stdenv.mkDerivation rec {
  pname = "timemory";
  version = "unstable";

  src = fetchFromGitHub {
    owner = "NERSC";
    repo = "timemory";
    rev = "ed7307626f647d5e14daf8d2c1bfc9903891ef4e";
    sha256 = "1pwn511pr08iy7bhvslw72c5zz5knkk7fqhsjq2vqcg24kk829bi";
  };

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    papi
    gperftools
  ];

}
