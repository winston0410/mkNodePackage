# mkNodePackage

A helper flake for building Node.js package easily.

## Why?

Writing derivations for Nix could be very difficult, and this flake tries to hide all the details and allow you to only use commands from Node ecosystem to build a derivation.

## How?

This flakes provide there following functions:

### `lib.mkNodePackage`

- Auto-detect package manager(`npm`, `yarn`) used in the target project, and build the project.

- Same type signature with `stdenv.mkDerivation`, yet [most are managed]()

### `lib.mkNodeModule`

- Auto-detect package manager used in the target project, and build the `node_modules`.

- Only accpet [a fetcher as `src`]()

### `lib.mkNpmPackage`

- Build the project for project using `npm`.

- Same type signature with `lib.mkNodePackage`.

### `lib.mkNpmModule`

- Build `node_modules` for project using `npm`. Use `npmlock2nix` under the hood.

- Same type signature with `lib.mkNodePackage`.

### `lib.mkYarnPackage`

- Build the project for project using `yarn`.

- Same type signature with `lib.mkNodePackage`.

### `lib.mkYarnModule`

- Build `node_modules` for project using `yarn`. Use `yarn2nix` under the hood.

- Same type signature with `lib.mkNodePackage`.
