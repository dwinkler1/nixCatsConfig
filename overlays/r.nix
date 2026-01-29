# R packages overlay
#
# This overlay provides access to R packages from rstats-on-nix and custom packages from fran.
#
# rstats-on-nix maintains snapshots of CRAN packages built with Nix:
# - Provides reproducible R package versions
# - Ensures binary cache availability for faster builds
# - Maintained by the rstats-on-nix community
#
# The fran overlay adds custom R packages and tools (radianWrapper, air-formatter).
#
# Available attributes after applying this overlay:
#   - pkgs.rpkgs: R packages from rstats-on-nix
#   - pkgs.rpkgs.rPackages: All CRAN packages
#   - pkgs.rpkgs.quarto: Quarto publishing system
#   - pkgs.rpkgs.rWrapper: R with package management
#   - pkgs.extraRPackages: Custom R packages from fran (if available)
#   - pkgs.radianWrapper: Enhanced R console from fran
#   - pkgs.air-formatter: R code formatter from fran
#
# To use specific R packages, reference them via:
#   with pkgs.rpkgs.rPackages; [ package1 package2 ]
#
# Update the R snapshot date in flake.nix inputs section:
#   rixpkgs.url = "github:rstats-on-nix/nixpkgs/YYYY-MM-DD"
{ rixpkgs, fran, ... }:
final: prev:
let
  # R packages from rstats-on-nix for the current system
  rpkgs = rixpkgs.legacyPackages.${prev.stdenv.hostPlatform.system};
  
  # Apply fran overlay to get custom R packages and tools
  franOverlay = fran.overlays.default final prev;
  
  # Standard R packages used by default in rWrapper and quarto
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
in
franOverlay
// {
  inherit rpkgs;
  
  # R wrapper with standard packages
  rWrapper = rpkgs.rWrapper.override { packages = reqPkgs; };
  
  # Quarto with R integration
  quarto = rpkgs.quarto.override { extraRPackages = reqPkgs; };
}
