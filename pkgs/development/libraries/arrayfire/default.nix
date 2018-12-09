{ fetchurl, stdenv
, cmake, pkgconfig
, spdlog, python
, enableCpuBackend ? false, openblasCompat, fftw, fftwFloat
, enableCudaBackend ? true, cudatoolkit
, enableOpenClBackend ? false, boost, opencl-clhpp, clblas, ocl-icd
}:

stdenv.mkDerivation rec{
  name = "arrayfire-${version}";
  version = "3.6.2";

  src = fetchurl {
    url = "http://arrayfire.com/arrayfire_source/arrayfire-full-${version}.tar.bz2";
    sha256 = "00p1d56s4qd3ll5f0980zwpw3hy8m6v0gd7v34rim4bkmslb8gvg";
  };

  nativeBuildInputs = [
    cmake
    pkgconfig
  ] ++ stdenv.lib.optionals enableCudaBackend [
    cudatoolkit
  ];

  buildInputs = [
    spdlog
    boost
    python
  ] ++ stdenv.lib.optionals enableCpuBackend [
    fftw
    fftwFloat
    openblasCompat
  ] ++ stdenv.lib.optionals enableOpenClBackend [
    opencl-clhpp
    clblas
    ocl-icd
  ];
  # TODO: https://github.com/arrayfire/arrayfire/blob/1b792bc3c12b6014079646d99c4f733c998d98af/src/backend/cpu/blas.cpp#L47
  preConfigure = ''
    export HOME=$(pwd) # Build tries to create $HOME/.cmake/packages/spdlog/*
  '';

  cmakeFlags = [
    "-DCMAKE_POLICY_DEFAULT_CMP0063=NEW"
    "-DCMAKE_POLICY_DEFAULT_CMP0074=NEW"
    "-DAF_BUILD_CPU=${if enableCpuBackend then "ON" else "OFF"}"
    "-DAF_BUILD_CUDA=${if enableCudaBackend then "ON" else "OFF"}"
    "-DAF_BUILD_OPENCL=${if enableOpenClBackend then "ON" else "OFF"}"
  ];

  meta = with stdenv.lib; {
    homepage = https://arrayfire.com/;
    license = stdenv.lib.licenses.bsd3;
    platforms = with platforms; linux;
    description = "A general purpose GPU library";
    longDescription = ''
      ArrayFire is a general-purpose library that simplifies the process of
      developing software that targets parallel and massively-parallel
      architectures including CPUs, GPUs, and other hardware acceleration
      devices.
    '';
    maintainers = with maintainers; [ knedlsepp ];
  };
}
