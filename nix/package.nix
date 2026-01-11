{
  self ? ../.,
  stdenv,
  cmake,
  ninja,
  doctest,
}:

stdenv.mkDerivation {
  pname = "luau-ng";
  version = "1.0.0";

  src = self;

  nativeBuildInputs = [
    cmake
    ninja
  ];

  checkInputs = [
    # TODO: https://github.com/NixOS/nixpkgs/issues/478885
    (doctest.overrideAttrs (old: {
      cmakeFlags = old.cmakeFlags ++ [
        "-DDOCTEST_WITH_TESTS=OFF"
      ];
    }))
  ];

  doCheck = true;

  outputs = [
    "bin"
    "out"
    "dev"
  ];
}
