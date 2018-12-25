{ stdenv, fetchurl, rpm, cpio, autoPatchelfHook, wrapCCWith }:
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
    nativeBuildInputs = [ rpm cpio autoPatchelfHook ];
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
      pushd opt/intel/compilers_and_libraries_*/linux/bin/
      patchShebangs link_install.sh
      ./link_install.sh -i -l $out -p $out/compilers_and_libraries_*
      popd
      runHook postInstall
    '';
    postInstall = ''
      # TODO: The offload_main program needs "libcoi_device.so.0"; not yet in nixpkgs.
      find $out -name offload_main -delete
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
      echo "export INTEL_LICENSE_FILE=${license}" >> $out/nix-support/add-flags.sh
    '';
  };
in intel_wrapped