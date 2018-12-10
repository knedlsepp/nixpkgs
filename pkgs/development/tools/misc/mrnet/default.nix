{ stdenv, fetchFromGitHub, which
}:
stdenv.mkDerivation rec{
  name = "mrnet-${version}";
  version = rev;
  rev = "5.0.3-pre";

  src = fetchFromGitHub {
    owner = "dyninst";
    repo = "mrnet";
    rev = "7375ba5bb0df87c68e58ad15e9e5e351ae020c08";
    sha256 = "073yx9xkw5hkjdakjix3jyg8qp723flksskwsq9scqx83c81n0p6";
  };

  nativeBuildInputs = [
  	which
  ];

  enableParallelBuilding = false;

}

