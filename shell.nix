{ nixpkgs ? import <nixpkgs> {}
, compiler ? "default"
}:
let
  haskellPackages = if compiler == "default"
    then nixpkgs.haskellPackages
    else nixpkgs.pkgs.haskell.packages.${compiler};

  cabal2nix = haskellPackages.cabal2nix;
  hlint = haskellPackages.hlint;
  cabal = haskellPackages.cabal-install;
  hindent = haskellPackages.hindent;

  env = (import ./default.nix { inherit nixpkgs compiler; }).env;
in
  nixpkgs.lib.overrideDerivation env (drv: {
    nativeBuildInputs = drv.nativeBuildInputs ++ [ hlint cabal hindent cabal2nix ];
  })
