{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs =
    {
      self,
      nixpkgs,
      ...
    }:
    let
      eachSystem = nixpkgs.lib.genAttrs [
        "x86_64-linux"
        "aarch64-linux"
        "riscv64-linux"
      ];
    in
    {
      formatter = eachSystem (system: with nixpkgs.legacyPackages.${system}; nixfmt);
      overlays.default = final: previous: {
        luau-ng = previous.callPackage ./nix/package.nix { inherit self; };
      };
      packages = eachSystem (
        system: with nixpkgs.legacyPackages.${system}; {
          luau-ng = callPackage ./nix/package.nix { inherit self; };
        }
      );
    };
}
