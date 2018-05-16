{ mkDerivation, base, JuicyPixels, optparse-applicative, stdenv }:
mkDerivation {
  pname = "stacker";
  version = "0.1.0.0";
  src = ./.;
  isLibrary = false;
  isExecutable = true;
  executableHaskellDepends = [
    base JuicyPixels optparse-applicative
  ];
  license = stdenv.lib.licenses.bsd3;
}
