{ lib
, buildPythonApplication
, fetchPypi
, hatch-requirements-txt
, hatch-vcs
, hatchling
, click
, click-default-group
, jinja2
, pydantic
, pyyaml
, ruamel_yaml
, filelock
, crashtest
, gitpython
, urllib3
, pkginfo
, ensureconda
, html5lib
, clikit
, virtualenv
, cachecontrol
, cachy
, keyring
, tomlkit
, toolz
, conda
}:

buildPythonApplication rec {
  pname = "conda-lock";
  version = "2.1.0";

  src = fetchPypi {
    pname = "conda_lock";
    inherit version;
    sha256 = "9973d463f609f4cad7fd69e5aeef7fcd4fbafb0e364056e78957121566dc2625";
  };

  format = "pyproject";

  propagatedBuildInputs = [
    conda
    cachy
    toolz
    tomlkit
    click
    click-default-group
    crashtest
    jinja2
    pydantic
    pyyaml
    ruamel_yaml
    hatch-requirements-txt
    hatch-vcs
    filelock
    gitpython
    urllib3
    pkginfo
    ensureconda
    html5lib
    keyring
    virtualenv
    cachecontrol
    cachecontrol.optional-dependencies.filecache
    clikit
  ];

  nativeBuildInputs = [
    hatchling
  ];

  meta = {
    description = "A library to generate fully reproducible lock files for conda environments";
    homepage = "https://github.com/conda/conda-lock";
    license = lib.licenses.mit;
  };
}
