{ pkgs ? import <nixpkgs> {}

, stackageSrc
, baseUrl
}:

import ./stackage {
  inherit pkgs stackageSrc baseUrl;
  names = [
    "lts-8.20"
    "lts-8.21"
    "lts-8.22"
    "lts-8.23"
    "lts-8.24"

    "lts-9.17"
    "lts-9.18"
    "lts-9.19"
    "lts-9.20"
    "lts-9.21"

    "lts-10.6"
    "lts-10.7"
    "lts-10.8"
    "lts-10.9"
    "lts-10.10"

    "lts-11.10"
    "lts-11.11"
    "lts-11.12"
    "lts-11.13"
    "lts-11.14"
  ];
}
