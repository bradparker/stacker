{ mkDerivation, base, JuicyPixels, stdenv }:
mkDerivation {
  pname = "stacker";
  version = "0.1.0.0";
  src = ./.;
  isLibrary = false;
  isExecutable = true;
  executableHaskellDepends = [ base JuicyPixels ];
  license = stdenv.lib.licenses.bsd3;
}
