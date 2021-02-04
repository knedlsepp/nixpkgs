{ stdenv, buildPythonPackage, fetchPypi
, rabbitpy
, pytest
}:

buildPythonPackage rec {
  pname = "port-for";
  version = "0.4";

  src = fetchPypi {
    inherit pname version;
    sha256 = "1pncxlj25ggw99r0ijfbkq70gd7cbhqdx5ivsxy4jdp0z14cpda7";
  };

  doCheck = false;
}
