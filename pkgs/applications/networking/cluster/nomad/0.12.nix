{ callPackage
, buildGoPackage
, nvidiaGpuSupport
}:

callPackage ./generic.nix {
  inherit buildGoPackage nvidiaGpuSupport;
  version = "0.12.12";
  sha256 = "0hz5fsqv8jh22zhs0r1yk0c4qf4sf11hmqg4db91kp2xrq72a0qg";
}
