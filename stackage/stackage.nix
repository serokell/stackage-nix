let
  inherit (builtins) attrNames attrValues fetchurl fromJSON  listToAttrs readFile;

  baseUrl = readFile ./baseUrl;
  sources = fromJSON (readFile ./sources.json);

  # We are creating overlays so better not to depend on nixpkgs yet
  mapAttrs = f: set:
    listToAttrs (map (attr: { name = attr; value = f attr set.${attr}; }) (attrNames set));

  importStackageOverlay = _: src:
    import (fetchTarball {
      url = "${baseUrl}/${src.file}";
      inherit (src) sha256;
    });

  overlays = mapAttrs importStackageOverlay sources;

in overlays // {
  _all = attrValues overlays;
}
