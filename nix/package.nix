{
  lib,
  self ? ../.,
  stdenv,
  cmake,
  ninja,
  doctest,
}:
stdenv.mkDerivation {
  pname = "luau-ng";
  version = "1.2.0";

  src = self;

  nativeBuildInputs = [
    cmake
    ninja
  ];

  checkInputs = [
    doctest
  ];

  doCheck = true;

  outputs = ["bin" "out" "dev"];

  # Don't enable LTO with gcc because ld.bfd is very slow
  cmakeFlags = lib.optionals (stdenv.hostPlatform.useLLVM) [
    "-DLUAU_ENABLE_LTO=OFF"
  ];
}
