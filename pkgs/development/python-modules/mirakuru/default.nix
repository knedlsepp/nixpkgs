{ stdenv, buildPythonPackage, fetchPypi
, psutil
, python-daemon
}:

buildPythonPackage rec {
  pname = "mirakuru";
  version = "2.3.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "1w2rhb9fiiwv84m0n44b59927hbfx1dh5kk1kj65pjnjxf3zb46b";
  };

  propagatedBuildInputs = [
    psutil
    python-daemon
  ];
  doCheck = false;
}
