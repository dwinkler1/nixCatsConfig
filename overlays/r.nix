{ rixpkgs, fran, ... }:
final: prev:
let
  rpkgs = rixpkgs.legacyPackages.${prev.stdenv.hostPlatform.system};
  reqPkgs = with rpkgs.rPackages; [
    arrow
    broom
    data_table
    devtools
    janitor
    languageserver
    quarto
    reprex
    styler
    tidyverse
  ];
  franOverlay = fran.overlays.default final prev;
in
franOverlay
// {
  inherit rpkgs;
  quarto = rpkgs.quarto.override { extraRPackages = reqPkgs; };
  rWrapper = rpkgs.rWrapper.override { packages = reqPkgs; };
}
