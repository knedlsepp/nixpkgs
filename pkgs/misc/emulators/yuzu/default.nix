{ lib, mkDerivation, fetchFromGitHub, boost, cmake, git, python2, perl, qtbase, SDL2 }:

mkDerivation rec {
  pname = "yuzu";
  version = "unstable-2020-01-01";

  src = fetchFromGitHub {
    owner = "yuzu-emu";
    repo = "yuzu";
    fetchSubmodules = true;
    deepClone = true;  # Yuzu's CMake submodule check uses .git presence.
    branchName = "master";  # For nicer in-app version numbers.
    rev = "028b2718ed9ce493058aa196d1b349163fb1d69a";
    sha256 = "0h1fn9sjh512gg1vw9f56kh5ndj79hcs91fjqi9fzb51yrbc1bz7";
  };

  nativeBuildInputs = [ cmake git perl python2 ];
  buildInputs = [ boost qtbase SDL2 ];

  cmakeFlags = [
    # Disable as much vendoring as upstream allows. We still use vendored
    # libunicorn since the fork used by Yuzu is significantly different.
    "-DYUZU_USE_BUNDLED_QT=OFF"
    "-DYUZU_USE_BUNDLED_SDL2=OFF"
    "-DYUZU_USE_BUNDLED_UNICORN=ON"
  ];

  meta = with lib; {
    description = "Experimental open-source emulator for the Nintendo Switch";
    homepage = "https://yuzu-emu.org";
    license = licenses.gpl2Plus;
    platforms = [ "x86_64-linux" ];
    maintainers = with maintainers; [ knedlsepp ];
  };
}
