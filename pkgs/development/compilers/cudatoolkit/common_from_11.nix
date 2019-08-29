args@{ gcc, version, sha256
, url ? ""
, name ? ""
, python ? python27
, runPatches ? []
, enableStatic ? true
, addOpenGLRunpath
, autoPatchelfHook
, alsaLib
, expat
, fetchurl
, fontconfig
, freeglut
, freetype
, gdk-pixbuf
, glib
, glibc
, gtk2
, jre
, lib
, libGLU
, libkrb5
, libxkbcommon
, libxml2
, makeWrapper
, ncurses5
, nspr
, nss
, perl
, pulseaudio
, python27
, requireFile
, stdenv
, unixODBC
, xorg
}:

stdenv.mkDerivation rec {
  name = "cudatoolkit-${version}";
  inherit version runPatches;

  dontStrip = true;

  src = fetchurl {
    inherit (args) url sha256;
  };

  unpackPhase = ''
    runHook preUnpack
    sh $src --keep --noexec
    cd pkg
    runHook postUnpack
  '';

  postPatch = ''
    sed -i -e 's,/tmp/cuda-installer.log,cuda-installer.log\x00xxxx,g' ./cuda-installer
    patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" ./cuda-installer
    autoPatchelf cuda-installer
  '';
  nativeBuildInputs = [
    addOpenGLRunpath
    autoPatchelfHook
    makeWrapper
  ];

  preBuild = ''
    ln -s $out/targets/x86_64-linux/lib/stubs/libcuda.so libcuda.so.1
    export LD_LIBRARY_PATH=$PWD
  '';

  buildInputs = [
    alsaLib
    fontconfig
    freeglut
    freetype
    gcc.cc
    glib
    glibc
    libGLU
    libkrb5
    libxkbcommon
    libxml2
    ncurses5
    nspr
    nss
    pulseaudio
    xorg.libX11
    xorg.libXcomposite
    xorg.libXcursor
    xorg.libXdamage
    xorg.libXext
    xorg.libXfixes
    xorg.libXtst
  ];
  installPhase = ''
    runHook preInstall
    ./cuda-installer --toolkit --installpath=$out/ --no-man-page --no-drm --override-driver-check --override --silent
    runHook postInstall
  '';
  postInstall = lib.optionalString (!enableStatic) ''
    find $out -name "*.a" -delete
  '' + ''
    echo "Showing installer logs:"
    cat cuda-installer.log
    for f in nvvp
    do
      wrapProgram $out/bin/$f \
        --set JAVA_HOME "${jre}" \
        --prefix PATH : "${lib.getBin jre}/bin" \
        --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ xorg.libX11 xorg.libXtst ]}
    done
  '';
  dontAutoPatchelf = true; # We manually run this before addOpenGLRunpath
  postFixup = ''
    autoPatchelf -- $(for output in $outputs; do
        [ -e "''${!output}" ] || continue
        echo "''${!output}"
    done)
    echo "Adding OpenGL runpath."
    # Some binaries will try to dlopen libcuda.so
    addOpenGLRunpath --force-rpath $out/bin/* $out/bin/.* $out/lib*/lib*.so
  '';
  doInstallCheck = true;
  postInstallCheck = let
  in ''
    # Smoke test binaries
    pushd $out/bin
    for f in *; do
      case $f in
        crt)                           continue;;
        cuda-uninstaller)              continue;;
        nvcc.profile)                  continue;;
        nsight_ee_plugins_manage.sh)   continue;;
        nsight-sys)                    continue;;
        nsys-exporter)                 continue;;
        ncu-ui)                        continue;;
        nsys-ui)                       continue;;
        nv-nsight-cu)                  continue;;
        uninstall_cuda_toolkit_6.5.pl) continue;;
        computeprof|nvvp|nsight)       continue;; # GUIs don't feature "--version"
        *)                             echo "Executing '$f --version':"; ./$f --version;;
      esac
    done
    popd
  '';
  passthru = {
    cc = gcc;
    majorVersion =
      let versionParts = lib.splitString "." version;
      in "${lib.elemAt versionParts 0}.${lib.elemAt versionParts 1}";
  };

  meta = with stdenv.lib; {
    description = "A compiler for NVIDIA GPUs, math libraries, and tools";
    homepage = "https://developer.nvidia.com/cuda-toolkit";
    platforms = [ "x86_64-linux" ];
    license = licenses.unfree;
  };
}
