{ pkgs, stdenv, npmlock2nix, yarn2nix, ... }:

let
  mkNpmModule = { pname, src, version, buildInputs, buildPhase, installPhase }:
    let
      nodeModules = npmlock2nix.node_modules { inherit src; };
      nmPath = "${nodeModules + /node_modules}";
    in (stdenv.mkDerivation {
      inherit pname version src;
      buildInputs = [ pkgs.nodejs ] ++ buildInputs;

      buildPhase = ''
        echo ${nodeModules};
        ln -s ${nmPath} ./node_modules
        ${buildPhase}
      '';
      installPhase = ''
        ${installPhase}
      '';
    });
in ({ pname, src, version, buildInputs ? [ ], buildPhase ? "npm run build"
  , installPhase ? ''
    mkdir -p $out
    cp -r dist $out
  '' }:
  let
    result = if (builtins.pathExists "${src}/package-lock.json") then
      (mkNpmModule {
        inherit pname src version buildInputs buildPhase installPhase;
      })
    else
      (if (builtins.pathExists "${src}/yarn.lock") then
        let
          yarnLock = "${src}/yarn.lock";
          packageJSON = "${src}/package.json";
        in (pkgs.mkYarnModule { inherit pname version yarnLock packageJSON; })
      else
        (abort "Cannot understand the lock file of this project"));
  in (result))
