{ callPackage
, buildGoPackage
, nvidiaGpuSupport
}:

callPackage ./generic.nix {
  inherit buildGoPackage nvidiaGpuSupport;
  version = "1.1.1";
  sha256 = "0y7p85dvxfgzaafgzdmnw3fp9h87zx3z8m1ka4qaiacwah5xwqlv";
}
