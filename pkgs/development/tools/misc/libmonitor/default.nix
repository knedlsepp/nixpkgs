{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec{
  name = "libmonitor-${version}";
  version = rev;
  rev = "d28cc1d3c08c02013a68a022a57a6ac73db88166";


  src = fetchFromGitHub {
    owner = "HPCToolkit";
    repo = "libmonitor";
    rev = "${version}";
    sha256 = "0w83jxsnnx2klk9y3yyd0z8ydiz1fh0y816mzrnw11v6amrmjvp4";
  };
  nativeBuildInputs = [
  ];

  buildInputs = [
  ];
}
