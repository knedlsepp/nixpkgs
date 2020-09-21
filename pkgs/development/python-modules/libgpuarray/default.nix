{ stdenv
, lib
, buildPythonPackage
, fetchFromGitHub
, cmake
, cython
, numpy
, six
, nose
, Mako
, addOpenGLRunpath
, cudaSupport ? true, cudatoolkit, nccl
, openclSupport ? true, ocl-icd, clblas
}:

assert cudaSupport -> cudatoolkit != null;

buildPythonPackage rec {
  pname = "libgpuarray";
  version = "0.7.6";

  src = fetchFromGitHub {
    owner = "Theano";
    repo = "libgpuarray";
    rev = "v${version}";
    sha256 = "0ksil18c9ign4xrv5k323flhvdy6wdxh8szdd3nivv31jc3zsdri";
  };

  # requires a GPU
  doCheck = false;

  configurePhase = "cmakeConfigurePhase";

  # libgpuarray.so wants to dlopen:
  #   libclBLAS.so: clblas
  #   libclblast.so: clblast (not yet packaged)
  #   libnvrtc.so: cudatoolkit (NVRTC)
  #   libcublast.so: cudatoolkit (cublas)
  #   libnccl.so: nccl
  #   libcuda.so: nvidia_x11 (via addOpenGLRunpath)
  #   libOpenCL.so: ocl-icd

  libraryPath = lib.makeLibraryPath (
    []
    ++ lib.optionals cudaSupport [ cudatoolkit.lib cudatoolkit.out nccl ]
    ++ lib.optionals openclSupport ([ clblas ] ++ lib.optional (!stdenv.isDarwin) ocl-icd)
  );

  preBuild = ''
    make -j$NIX_BUILD_CORES
    make install

    export NIX_CFLAGS_COMPILE="-L $out/lib -I $out/include $NIX_CFLAGS_COMPILE"

    cd ..
  '';

  postFixup = ''
    rm $out/lib/libgpuarray-static.a
  '' + lib.optionalString (!stdenv.isDarwin) ''
    function fixRunPath {
      p=$(patchelf --print-rpath $1)
      patchelf --set-rpath "$p:$libraryPath" $1
    }

    fixRunPath $out/lib/libgpuarray.so
    addOpenGLRunpath $out/lib/libgpuarray.so
  '';

  propagatedBuildInputs = [
    numpy
    six
    Mako
  ];

  nativeBuildInputs = [ cmake addOpenGLRunpath ];

  buildInputs = [
    cython
    nose
  ];

  meta = with lib; {
    homepage = "https://github.com/Theano/libgpuarray";
    description = "Library to manipulate tensors on GPU.";
    license = licenses.free;
    maintainers = with maintainers; [ artuuge ];
    platforms = platforms.unix;
  };

}
