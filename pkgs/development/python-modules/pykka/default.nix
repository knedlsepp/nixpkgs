{ stdenv
, buildPythonPackage
, fetchFromGitHub
}:

buildPythonPackage rec {
  pname = "pykka";
  version = "2.0.2";

  src = fetchFromGitHub {
    owner = "jodal";
    repo = "pykka";
    rev = "v${version}";
    sha256 = "08j1f4rb32xyxnilfr6jd537d1zqb5zy8x2f403j01gq5jr0yjxn";
  };

  # There are no tests
  doCheck = false;

  meta = with stdenv.lib; {
    homepage = http://www.pykka.org;
    description = "A Python implementation of the actor model";
    license = licenses.asl20;
    maintainers = [];
  };

}
