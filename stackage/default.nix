# Package all stackage snapshots in the given stackage revision

{ pkgs

, stackageSrc
, names        # TODO: remove; get names from the snapshot
, baseUrl
}:

let
  inherit (pkgs) symlinkJoin;
  inherit (pkgs.lib) concatMapStringsSep;

  snapshot = import ./snapshot { inherit pkgs stackageSrc; };

  # Works only for lists of string
  toNix = expr:
    "[ " + concatMapStringsSep " " (s: ''"${s}"'') expr + " ]";

in

symlinkJoin {
  name = "stackage";
  paths = map snapshot names;

  nativeBuildInputs = [ pkgs.nix ];

  postBuild = ''
    mkdir -p stackage

    exec 4<&1
    exec >stackage/sources.json
    echo "{"
  '' + concatMapStringsSep "echo ,\n" (n: ''
    printf '"${n}": {"file": "${n}.tar.gz", "sha256": "'
    nix-prefetch-url --type sha256 --unpack "file://$out/${n}.tar.gz" | tr -d "\n"
    printf '"}'
  '') names + ''
    echo ""
    echo "}"
    exec 1<&4
    cp stackage/sources.json "$out/"

    cp "${./stackage.nix}" stackage/default.nix
    printf '"%s/%s"' "${baseUrl}" $(basename "$out") > stackage/baseUrl.nix


    tar -czf "$out/default.nix.tar.gz" stackage/

    nix-prefetch-url --type sha256 --unpack "file://$out/default.nix.tar.gz" >"$out/default.nix.tar.gz.sha256"
  '';
}
