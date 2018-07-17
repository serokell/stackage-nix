# Package a single stackage snapshot at the given stackage revision
# TODO: this is quick and dirty implementation

{ pkgs
, stackageSrc
}:

snapshotName:

pkgs.stdenvNoCC.mkDerivation {
  name = "stackage-${snapshotName}";

  src = stackageSrc;

  nixpkgsStackage = fetchTarball {
    url = "https://github.com/typeable/nixpkgs-stackage/archive/53db4b166083834d6b9bccb6826ae62586b56dd3.tar.gz";
    sha256 = "0axb0jhrwlswfl8yma23i2jkbqjbq88iykhr0sh5accpvd81pa3l";
  };

  nativeBuildInputs = [ pkgs.nix ];

  phases = [ "unpackPhase" "buildPhase" "installPhase" ];

  buildPhase = ''
    mkdir -p "$NIX_BUILD_TOP/snapshot"
    cd "$NIX_BUILD_TOP/snapshot"

    cp "$nixpkgsStackage/stackage/${snapshotName}/"* ./
    mv default.nix set.nix
    echo 'let name = "${snapshotName}"; in' > default.nix
    cat ${./snapshot.nix} >> default.nix
  '';

  installPhase = ''
    mkdir -p "$out"
    archive="$out/${snapshotName}.tar.gz"
    cd "$NIX_BUILD_TOP"
    tar -czf "$archive" snapshot
  '';
}
