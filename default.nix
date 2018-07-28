{ pkgs ? import <nixpkgs> {}

, stackageSrc
, baseUrl
}:

import ./stackage {
  inherit pkgs stackageSrc baseUrl;
}
