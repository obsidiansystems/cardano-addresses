{-# LANGUAGE CPP #-}

module Cardano.Mnemonic.Compat
  ( getEntropy )
  where

import qualified Data.ByteArray as BA
import Prelude

#ifdef ghcjs_HOST_OS
import qualified System.Entropy as Entropy
#else
import qualified Crypto.Random.Entropy as Crypto
#endif

getEntropy :: BA.ByteArray byteArray => Int -> IO byteArray
getEntropy n =
#ifdef ghcjs_HOST_OS
  fmap BA.convert $ Entropy.getEntropy n
#else
  Crypto.getEntropy n
#endif
