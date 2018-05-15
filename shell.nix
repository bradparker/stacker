{ nixpkgs ? import <nixpkgs> {}
, compiler ? "default"
}:
let
  haskellPackages = if compiler == "default"
    then nixpkgs.haskellPackages
    else nixpkgs.pkgs.haskell.packages.${compiler};

  hlint = haskellPackages.hlint;
  cabal = haskellPackages.cabal-install;
  hindent = haskellPackages.hindent;

  env = (import ./default.nix { inherit nixpkgs compiler; }).env;
in
  nixpkgs.lib.overrideDerivation env (drv: {
    nativeBuildInputs = drv.nativeBuildInputs ++ [ hlint cabal hindent ];
  })
