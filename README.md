# mkNodePackage

A helper flake for building Node.js package easily with Nix.

## Why?

Writing derivations for Nix could be very difficult, and this flake tries to hide all the details and allow you to only use commands from Node ecosystem to build a derivation.

## Usage example

### Build a derivation and save it in `XDG_DATA_HOME`

```nix
{ pkgs, config, inputs, system, ... }:

let xdg = config.xdg;
in {
  # Prettier plugin
  home.file = let
    prettierPluginDir = "${xdg.dataHome}/prettier/node_modules";
  in {
    "${prettierPluginDir}/@prettier/plugin-pug" = let 
        version = "743f5aafa11d161537bbcd614fe5af81944a8d2f";
    in{
      source = (inputs.mkNodeModule.lib.${system}.mkNodePackage {
        pname = "prettier-plugin-pug";
        inherit version;
        src = pkgs.fetchFromGitHub {
          owner = "winston0410";
          repo = "plugin-pug";
          rev = version;
          sha256 = "sha256-SUH94XnD0a0JX3SQQmHB9SWnS7oVP9BiBcS9a7o4wm0=";
        };
        buildPhase = ''
        npm run build
        '';
        
        installPhase = ''
        mkdir -p $out
        cp -r dist $out
        '';
      });
    };
  };
}
```

## API Reference

This flakes provide there following functions:

### `lib.${system}.mkNodePackage`

- Auto-detect package manager(`npm`, `yarn`) used in the target project, and build the project.

- Same type signature with `stdenv.mkDerivation`, yet [most are managed](https://github.com/winston0410/mkNodeModule/blob/5c1f2bf09fbce0b4c675b5e6a5fd27c84f52159e/lib.nix#L98)

### `lib.${system}.mkNodeModule`

- Auto-detect package manager used in the target project, and build the `node_modules`.

- Only accpet [a fetcher as `src`](https://github.com/winston0410/mkNodeModule/blob/5c1f2bf09fbce0b4c675b5e6a5fd27c84f52159e/lib.nix#L88)

### `lib.${system}.mkNpmPackage`

- Build the project for project using `npm`.

- Same type signature with `lib.${system}.mkNodePackage`.

### `lib.${system}.mkNpmModule`

- Build `node_modules` for project using `npm`. Use `npmlock2nix` under the hood.

- Same type signature with `lib.${system}.mkNodePackage`.

### `lib.${system}.mkYarnPackage`

- Build the project for project using `yarn`.

- Same type signature with `lib.${system}.mkNodePackage`.

### `lib.${system}.mkYarnModule`

- Build `node_modules` for project using `yarn`. Use `yarn2nix` under the hood.

- Same type signature with `lib.${system}.mkNodePackage`.
