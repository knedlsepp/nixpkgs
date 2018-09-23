{ stdenv, fetchFromGitHub, cmake, flex }:
stdenv.mkDerivation rec {
  name = "nyan-unstable-${version}";
  version = "2018-09-23";
  src = fetchFromGitHub {
    owner = "SFTtech";
    repo = "nyan";
    rev = "702984ff93a1341d6b1b3a6a686ffc8d60687bee";
    sha256 = "1wnzj585p27v792ly52dp6kshawj7zzagbgh76124jaf18snysx5";
  };

  nativeBuildInputs = [
    cmake
    flex
  ];

  meta = with stdenv.lib; {
    description = "Modding API with a typesafe hierarchical key-value database";
    homepage = https://github.com/SFTtech/nyan;
    license = licenses.gpl3Plus;
    maintainers = [ maintainers.knedlsepp ];
    platforms = platforms.all;
  };
}
