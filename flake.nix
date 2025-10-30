{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    systems.url = "github:nix-systems/default";
  };

  outputs = {
    self,
    nixpkgs,
    systems,
    ...
  }: let
    eachSystem = nixpkgs.lib.genAttrs (import systems);
  in {
    formatter = eachSystem (system: with nixpkgs.legacyPackages.${system}; alejandra);
    overlays.default = final: previous: {
      luau-ng = previous.callPackage ./nix/package.nix {inherit self;};
    };
    packages = eachSystem (system:
      with nixpkgs.legacyPackages.${system}; {
        luau-ng = callPackage ./nix/package.nix {inherit self;};
      });
  };
}
