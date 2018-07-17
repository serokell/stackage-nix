_Stackage snapshots for your Nix._

This project is part of [`serokell-stackage`][serokell-stackage]. Please, see the readme there for details.

## Snapshots

Each stackage snapshot is converted into a `nixpkgs` overlay and then compressed individually so that you
can fetch just the archive for the snapshot which you will be using saving bandwidth and time.


## Output

The output of the nix expression contains the following:

* `default.nix.tar.gz` – `default.nix` in an archive suitable for `fetchTarball`
* `default.nix.tar.gz.sha256` – hash of `default.nix.tar.gz` (for fetching with `fetchTarball`)
* `sources.json` – hashes of archives with individual snapshot overlays used internally by `default.nix`
* `<snapshot-name>.tar.gz` – archives with actual overlays

`default.nix` will fetch the right archive depending on the snapshot that you want. To do this
it needs to know absolute URIs of the archives, therefore it has the `baseUrl` parameter and
it additionally appends its own output name to it, so that multiple generations can be hosted
at the same place.


## Usage

* Either `fetchTarball` the exact snapshot overlay archive that you want
(to make sure your derivation will work in a sandbox, grab the hash from `sources.json`)
* or `fetchTarball` `default.nix.tar.gz` (grab the hash from `default.nix.tar.gz.sha256`)
and then use the attribute with the name of the stackage snapshot you need – it will fetch
the right tarball for you.


  [serokell-stackage]: https://github.com/serokell/serokell-stackage
