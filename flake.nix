{
  description = "mkNodeModule";

  inputs = {
    nixpkgs = { url = "github:nixos/nixpkgs/nixos-unstable"; };
    npmlock2nix = {
      url = "github:winston0410/npmlock2nix/issue113";
      flake = false;
    };
    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs = { nixpkgs.follows = "nixpkgs"; };
    };
  };

  outputs = { nixpkgs, flake-utils, npmlock2nix, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system};
      in {
        lib = {
          build = (pkgs.callPackage ./lib.nix {
            npmlock2nix = pkgs.callPackage npmlock2nix { };
            yarn2nix = pkgs.yarn2nix;
          });
        };
      });
}
