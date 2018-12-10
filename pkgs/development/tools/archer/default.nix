{ clangStdenv, fetchFromGitHub, cmake, llvmPackages_6 }:

clangStdenv.mkDerivation rec {
  name = "archer-${version}";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "PRUNERS";
    repo = "archer";
    rev = "v${version}";
    sha256 = "00vj2g5nbdhnczrym65n3l44r99wcd28wknwlwdq76klb62d7bc8";
  };



  postPatch = ''
    substituteInPlace ./tools/clang-archer.in --replace "@LLVM_ROOT@/bin/" "${llvmPackages_6.clang}/bin/"
    substituteInPlace ./tools/clang-archer++.in --replace "@LLVM_ROOT@/bin/" "${llvmPackages_6.clang}/bin/"
  '';



  cmakeFlags = [
    "-DOMP_PREFIX=${llvmPackages_6.openmp}"
  ];

  nativeBuildInputs = [
    cmake
    llvmPackages_6.llvm
    llvmPackages_6.openmp
  ];

  meta = with clangStdenv.lib; {
    homepage = http://www.boost.org/archer2/;
    platforms = platforms.unix;
    maintainers = with maintainers; [ knedlsepp ];
  };
}
