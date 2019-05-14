{ pkgs

, stackageSrc  # unused
, baseUrl
}:

pkgs.stdenvNoCC.mkDerivation {
  name = "stackage";

  src = fetchTarball {
    url = "https://github.com/typeable/nixpkgs-stackage/archive/6042df5e646d65b826add0a85d16304bee8e1dd5.tar.gz";
    sha256 = "09x9985f2dram7hqj9v23bc5y8nr136d69l7wchsa1kcvql0pa1b";
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
      nix-hash --type sha256 --base32 source/stackage/"$snapshotName" | tr -d "\n"
      echo '"},'
    done
    exec 1<&4
    sed -e '$s/^\(.*\),$/\1\n}/' -i stackage/sources.json

    cp stackage/sources.json "$out/"

    echo "Building root archive"
    cp "${./stackage.nix}" stackage/default.nix
    printf "${baseUrl}/$(basename "$out")" > stackage/baseUrl

    tar -czf "$out/default.nix.tar.gz" stackage/

    nix-hash --type sha256 --base32 stackage/ > $out/default.nix.tar.gz.sha256
  '';
}
