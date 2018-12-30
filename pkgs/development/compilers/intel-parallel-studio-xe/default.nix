{ stdenv, fetchurl, rpm, cpio, autoPatchelfHook, wrapCCWith, makeWrapper}:
let
  license = /tmp/intel.lic;
  gcc = if stdenv.cc.isGNU then stdenv.cc.cc else stdenv.cc.cc.gcc;
  intel_unwrapped = stdenv.mkDerivation rec {
    name = "intel-compilers-${version}";
    version = "2018_update3";
    src = fetchurl {
      url = "http://registrationcenter-download.intel.com/akdlm/irc_nas/tec/12998/parallel_studio_xe_${version}_cluster_edition.tgz";
      sha256 = "11wjjaj0mc4w874dchaygz4qar58qvsf0jkvxyp6w1d5rs44pii3";
    };
    nativeBuildInputs = [ rpm cpio autoPatchelfHook makeWrapper ];
    buildInputs = [ stdenv.cc.cc.lib ];
    installPhase = let
      rpms = [ "intel-c-*.rpm" "intel-comp-*" "intel-icc-*.rpm" "intel-openmp-*.rpm"];
    in ''
      runHook preInstall
      cd rpm
      rm *32bit* # TODO: Support i686-linux
      for f in ${stdenv.lib.concatStringsSep " " rpms}; do
        echo "Extracting $f"
        rpm2cpio $f | cpio -idmv
      done
      mkdir -p $out
      cp -r opt/intel/compilers_and_libraries_* $out/
      COMP_LIB_INSTALLDIR=$(echo $out/compilers_and_libraries_*\.*/linux)
      for f in $COMP_LIB_INSTALLDIR/bin/*.sh $COMP_LIB_INSTALLDIR/bin/intel64/*.sh \
               $COMP_LIB_INSTALLDIR/bin/*.csh $COMP_LIB_INSTALLDIR/bin/intel64/*.csh; do
        echo "Patching $f"
        substituteInPlace $f --replace '<INSTALLDIR>' "$COMP_LIB_INSTALLDIR"
      done
      pushd opt/intel/compilers_and_libraries_*/linux/bin/  
      patchShebangs link_install.sh
      ./link_install.sh -i -l $out -p $out/compilers_and_libraries_*
      popd
      runHook postInstall
    '';
    postInstall = ''
      # TODO: The offload_main program needs "libcoi_device.so.0"; not yet in nixpkgs.
      find $out -name offload_main -delete

      # icc/icpc make a call to "gcc -print-search-dirs", so they need gcc in PATH
      # otherwise we get: "Requires 'install path' setting gathered from 'gcc'"
      for f in icc icpc xild xiar; do
        wrapProgram $out/bin/$f \
          --run "source $out/bin/compilervars.sh intel64" \
          --prefix PATH : "${stdenv.lib.makeBinPath [ stdenv.cc ]}"
      done
      # TODO: Use xild
    '';
    passthru = {
      isIntel = true;
      hardeningUnsupportedFlags = [ "stackprotector" ];
    } // stdenv.lib.optionalAttrs stdenv.isLinux {
      inherit gcc;
    };

    meta = with stdenv.lib; {
      homepage = "TODO";
      license = licenses.unfree;
      platforms = [ "x86_64-linux" ];
      description = "TODO";
      longDescription = ''
        TODO
      '';
      maintainers = with maintainers; [ knedlsepp ];
    };
  };
  intel_wrapped = wrapCCWith {
    cc = intel_unwrapped;
    extraBuildCommands = ''
      # TODO: Clean up. Put in correct file. Make configurable.
      echo 'export INTEL_LICENSE_FILE=${license}' >> $out/nix-support/add-flags.sh
      echo 'set +u; source ${intel_unwrapped}/bin/compilervars.sh intel64; set -u' >> $out/nix-support/setup-hook
      # Where the F is: mcpcom
      echo 'LIBRARY_PATH="${intel_unwrapped}/compilers_and_libraries_2018.3.222/linux/compiler/lib/intel64_lin/"'  >> $out/nix-support/setup-hook
      echo 'LD_LIBRARY_PATH="${intel_unwrapped}/compilers_and_libraries_2018.3.222/linux/compiler/lib/intel64_lin/"'  >> $out/nix-support/setup-hook
      echo 'echo "GRML"'  >> $out/nix-support/setup-hook
      echo 'echo "$LD_LIBRARY_PATH"'  >> $out/nix-support/setup-hook
    '';
  };
in intel_wrapped