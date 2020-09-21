{ callPackage
, buildGoPackage
, nvidiaGpuSupport
}:

callPackage ./generic.nix {
  inherit buildGoPackage nvidiaGpuSupport;
  version = "1.0.7";
  sha256 = "12izilr2x9qw8dxhjqcivakwzhf6jc86g0pmxf52fr9rwaqmpc95";
}
