{ stdenv, lib, buildPythonPackage, fetchFromGitHub
, rabbitpy
, rabbitmq-server
, port-for
, mirakuru
, pytest
, pytestCheckHook
, pytestcov
, pytest_xdist
}:

buildPythonPackage rec {
  pname = "pytest-rabbitmq";
  version = "2.1.0";

  src = fetchFromGitHub {
    owner = "ClearcodeHQ";
    repo = "pytest-rabbitmq";
    rev = "v${version}";
    sha256 = "1hbpylj1zfarj44idw28xdk2xq3dx99bgzdnr0qqz8vbqkf01lnx";
  };

  preBuild = ''
    substituteInPlace src/pytest_rabbitmq/plugin.py \
      --replace "/usr/lib/rabbitmq/bin/rabbitmqctl" "${lib.getBin rabbitmq-server}/bin/rabbitmqctl" \
      --replace "/usr/lib/rabbitmq/bin/rabbitmq-server" "${lib.getBin rabbitmq-server}/bin/rabbitmq-server"
  '';
  propagatedBuildInputs = [
    rabbitpy
    mirakuru
    port-for
  ];

  preCheck = ''
    export HOME=$(mktemp -d) # Otherwise we fail to write /homeless-shelter/.erlang.cookie
  '';
  checkInputs = [
    pytestcov
    pytest
    pytestCheckHook
    pytest_xdist
  ];

}
