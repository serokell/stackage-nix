{ pkgs

, stackageSrc  # unused
, baseUrl
}:

pkgs.stdenvNoCC.mkDerivation {
  name = "stackage";

  src = fetchTarball {
    url = "https://github.com/typeable/nixpkgs-stackage/archive/53db4b166083834d6b9bccb6826ae62586b56dd3.tar.gz";
    sha256 = "0axb0jhrwlswfl8yma23i2jkbqjbq88iykhr0sh5accpvd81pa3l";
  };

  nativeBuildInputs = [ pkgs.nix ];

  phases = [ "unpackPhase" "buildPhase" ];

  buildPhase = ''
    mkdir -p "$out"


    ##
    # Build archives with individual snapshots
    ##

    cd stackage
    local snapshots=$(ls -d lts-*)
    for snapshotName in $snapshots; do
      echo "Generating archive for $snapshotName"
      mv "$snapshotName/default.nix" "$snapshotName/set.nix"
      printf "$snapshotName" > "$snapshotName/name"
      cat "${./snapshot.nix}" >> "$snapshotName/default.nix"
      tar -czf "$out/$snapshotName.tar.gz" "$snapshotName"
    done


    ##
    # Now build the index
    ##

    cd "$NIX_BUILD_TOP"
    mkdir -p stackage

    echo "Generating sources.json"
    exec 4<&1
    exec >stackage/sources.json
    echo "{"
    for snapshotName in $snapshots; do
      printf '"%s": {"file": "%s.tar.gz", "sha256": "' "$snapshotName" "$snapshotName"
      nix-prefetch-url --type sha256 --unpack "file://$out/$snapshotName.tar.gz" | tr -d "\n"
      echo '"},'
    done
    exec 1<&4
    sed -e '$s/^\(.*\),$/\1\n}/' -i stackage/sources.json

    cp stackage/sources.json "$out/"

    echo "Building root archive"
    cp "${./stackage.nix}" stackage/default.nix
    printf "${baseUrl}/$(basename "$out")" > stackage/baseUrl

    tar -czf "$out/default.nix.tar.gz" stackage/

    nix-prefetch-url --type sha256 --unpack "file://$out/default.nix.tar.gz" >"$out/default.nix.tar.gz.sha256"
  '';
}
