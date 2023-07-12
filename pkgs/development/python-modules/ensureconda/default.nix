{ lib
, buildPythonPackage
, fetchPypi
, hatchling
, hatch-vcs
, click
, requests
, filelock
, appdirs
}:

buildPythonPackage rec {
  pname = "ensureconda";
  version = "1.4.3";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-4Eri4vhyhp3359oi3Mqb18Qvg5pVFV3dskm83J5qrkg=";
  };

  format = "pyproject";

  propagatedBuildInputs = [
    click
    appdirs
    filelock
    requests
  ];

  nativeBuildInputs = [
    hatchling
    hatch-vcs
  ];

  meta = {
    description = "Simple installer for conda";
    homepage = "https://github.com/conda-incubator/ensureconda";
    license = lib.licenses.mit;
  };
}
