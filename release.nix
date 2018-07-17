{ pkgs ? import <nixpkgs> {} }:

let
  stackageRev = "b69b9987e989c925c2bc467f409b259fe248106f";
  stackageSha = "0p31hnnn6fdni3mr142bwnl0kdgx39m3jc9py3qvdfy1nbdmvakz";
in

import ./. {
  inherit pkgs;
  stackageSrc = fetchTarball {
    url = "https://github.com/commercialhaskell/lts-haskell/archive/${stackageRev}.tar.gz";
    sha256 = stackageSha;
  };
  baseUrl = "file:///nix/store";
}
