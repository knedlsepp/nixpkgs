{ stdenv, stdenvGcc6, lib
, fetchFromGitHub, cmake, libmicrohttpd_0_9_70, openssl
, opencl-headers, ocl-icd, hwloc, cudatoolkit
, cudaSupport
, openclSupport ? true
, devDonationLevel ? "0.0"
, addOpenGLRunpath
}:

let
  stdenv' = if cudaSupport then stdenvGcc6 else stdenv;
in

stdenv'.mkDerivation rec {
  name = "xmr-stak-${version}";
  version = "2.10.8";

  src = fetchFromGitHub {
    owner = "fireice-uk";
    repo = "xmr-stak";
    rev = version;
    sha256 = "0ilx5mhh91ks7dwvykfyynh53l6vkkignjpwkkss8ss6b2k8gdbj";
  };

  NIX_CFLAGS_COMPILE = "-O3";

  cmakeFlags = [
    "-DCUDA_ENABLE=${if cudaSupport then "ON" else "OFF"}"
  ] ++ lib.optionals (openclSupport) [
    "-DOpenCL_ENABLE=ON"
  ];

  nativeBuildInputs = [
    addOpenGLRunpath
    cmake
  ] ++ lib.optional cudaSupport cudatoolkit;

  buildInputs = [ libmicrohttpd_0_9_70 openssl hwloc ]
    ++ lib.optionals openclSupport [ opencl-headers ocl-icd ];

  postPatch = ''
    substituteInPlace xmrstak/donate-level.hpp \
      --replace 'fDevDonationLevel = 2.0' 'fDevDonationLevel = ${devDonationLevel}'

    # Prevent runtime dependency on cudatoolkit
    substituteInPlace CMakeLists.txt \
      --replace 'target_link_libraries(xmrstak_cuda_backend ''${CUDA_LIBRARIES})' ""
  '';

  postFixup = lib.optionalString cudaSupport ''
    addOpenGLRunpath $out/bin/libxmrstak_cuda_backend.so
  '';

  disallowedReferences = [ cudatoolkit ];

  meta = with lib; {
    description = "Unified All-in-one Monero miner";
    homepage = "https://github.com/fireice-uk/xmr-stak";
    license = licenses.gpl3Plus;
    platforms = [ "x86_64-linux" ];
    maintainers = with maintainers; [ fpletz bfortz ];
  };
}
