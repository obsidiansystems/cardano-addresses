# This module adds the emscripten compiled dependencies of cardano-addresses-jsbits
{ pkgs, config, ... }:
let
  # Run the script to build the C sources from cryptonite and cardano-crypto
  # and place the result in jsbits/cardano-crypto.js
  jsbits = pkgs.runCommand "cardano-addresses-jsbits" {} ''
    script=$(mktemp -d)
    cp -r ${./.}/* $script
    ln -s ${pkgs.srcOnly {name = "cryptonite-src"; src = config.packages.cryptonite.src;}}/cbits $script/cryptonite
    ln -s ${pkgs.srcOnly {name = "cardano-crypto-src"; src = config.packages.cardano-crypto.src;}}/cbits $script/cardano-crypto
    patchShebangs $script/build.sh
    (cd $script && PATH=${
        # The extra buildPackages here is for closurecompiler.
        # Without it we get `unknown emulation for platform: js-unknown-ghcjs` errors.
        pkgs.lib.makeBinPath (with pkgs.buildPackages.buildPackages;
          [emscripten closurecompiler coreutils])
      }:$PATH ./build.sh)
    mkdir -p $out
   cp $script/cardano-crypto.js $out
  '';
  addJsbits = ''
    rm jsbits/*
    cp ${jsbits}/* jsbits
  '';
in {
  packages.cardano-addresses-jsbits.components.library.preConfigure = addJsbits;
}