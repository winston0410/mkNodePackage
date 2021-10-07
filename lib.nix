{ pkgs, stdenv, npmlock2nix, yarn2nix, ... }:

let
  mkNpmModule = { src }: npmlock2nix.node_modules { inherit src; };
  mkNpmPackage = { pname, src, version, buildInputs, buildPhase, installPhase }:
    let
      nodeModules = mkNpmModule { inherit src; };
      nmPath = "${nodeModules + /node_modules}";
    in (stdenv.mkDerivation {
      inherit pname version src;
      buildInputs = with pkgs; [ nodejs ] ++ buildInputs;

      buildPhase = ''
        ln -s ${nmPath} ./node_modules
        ${buildPhase}
      '';
      installPhase = ''
        ${installPhase}
      '';
    });
  mkYarnModule = { src }:
    let
      yarnDrv = pkgs.runCommand "yarn2nix" { } ''
        ${yarn2nix}/bin/yarn2nix --lockfile="${src}/yarn.lock" --no-patch --builtin-fetchgit > "$out"
      '';

      offlineCache = (pkgs.callPackage yarnDrv { }).offline_cache;

      defaultYarnFlags = [
        "--offline"
        "--frozen-lockfile"
        "--ignore-engines"
        "--ignore-scripts"
      ];
    in (stdenv.mkDerivation {
      name = "node_modules";
      #NOTE Need to have nodejs here, or else patchShebangs won't work correctly
      #REF https://discourse.nixos.org/t/what-is-the-patchshebangs-command-in-nix-build-expressions/12656
      buildInputs = with pkgs; [ nodejs yarn ];
      dontUnpack = true;
      buildPhase = ''
        source $stdenv/setup
        export HOME=$(pwd)
        yarn config set yarn-offline-mirror ${offlineCache}

        cp ${src + /package.json} ./package.json
        cp ${src + /yarn.lock} ./yarn.lock

        chmod +wx ./yarn.lock

        ${pkgs.fixup_yarn_lock}/bin/fixup_yarn_lock ./yarn.lock

        yarn install ${lib.escapeShellArgs defaultYarnFlags}
      '';

      installPhase = ''
        mkdir -p "$out"

        if test -d node_modules; then
        mv node_modules "$out"/

        if test -d "$out"/node_modules/.bin; then
        patchShebangs "$out"/node_modules/.bin/tsc
        ln -s "$out"/node_modules/.bin "$out"/bin
        fi
        fi 
      '';
    });
  mkYarnPackage =
    { pname, src, version, buildInputs, buildPhase, installPhase }:
    let
      nodeModules = mkYarnModule { inherit src; };
      nmPath = "${nodeModules + /node_modules}";
    in (stdenv.mkDerivation {
      inherit pname version src;
      buildInputs = with pkgs; [ nodejs ] ++ buildInputs;

      buildPhase = ''
        export HOME=$(pwd)
        ln -s ${nmPath} ./node_modules
        ${buildPhase}
      '';
      installPhase = ''
        ${installPhase}
      '';
    });
in {
  inherit mkNpmModule mkNpmPackage mkYarnModule mkYarnPackage;
  mkNodeModule = { src }:
    let
      handler = if (builtins.pathExists "${src}/package-lock.json") then
        mkNpmModule
      else
        (if (builtins.pathExists "${src}/yarn.lock") then
          mkYarnModule
        else
          (abort "Cannot understand the lock file of this project"));
    in (handler { inherit src; });
  mkNodePackage =
    ({ pname, src, version, buildInputs ? [ ], buildPhase, installPhase }:
      let
        handler = if (builtins.pathExists "${src}/package-lock.json") then
          mkNpmPackage
        else
          (if (builtins.pathExists "${src}/yarn.lock") then
            mkYarnPackage
          else
            (abort "Cannot understand the lock file of this project"));
      in (handler {
        inherit pname src version buildInputs buildPhase installPhase;
      }));
}
