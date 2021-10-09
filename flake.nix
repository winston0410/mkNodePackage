{
  description = "mkNodeModule";

  inputs = {
    nixpkgs = { url = "github:nixos/nixpkgs/nixos-unstable"; };
    npmlock2nix = {
      url = "github:winston0410/npmlock2nix/issue113";
      flake = false;
    };
    pnpm2nix = {
      url = "github:nix-community/pnpm2nix/master";
      flake = false;
    };
    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs = { nixpkgs.follows = "nixpkgs"; };
    };
  };

  outputs = { nixpkgs, flake-utils, npmlock2nix, pnpm2nix, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system};
      in {
        lib = (pkgs.callPackage ./lib.nix {
          npmlock2nix = pkgs.callPackage npmlock2nix { };
          yarn2nix = pkgs.yarn2nix;
          pnpm2nix = pkgs.callPackage pnpm2nix { };
        });
      });
}
