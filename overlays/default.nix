{ nixpkgs, ... }@inputs:
let
  lib = nixpkgs.lib;

  rOverlay = import ./r.nix inputs;
  pythonOverlay = import ./python.nix inputs;
  juliaOverlay = import ./julia.nix inputs;
  pluginsOverlay = import ./plugins.nix inputs;

  dependencyOverlays = [
    rOverlay
    pythonOverlay
    juliaOverlay
    pluginsOverlay
  ];
  dependencyOverlay = lib.composeManyExtensions dependencyOverlays;
in
{
  inherit
    rOverlay
    pythonOverlay
    juliaOverlay
    pluginsOverlay
    dependencyOverlays
    dependencyOverlay;

  # Named exports for downstream composition.
  default = dependencyOverlay;
  dependencies = dependencyOverlays;

  overlays = {
    inherit
      rOverlay
      pythonOverlay
      juliaOverlay
      pluginsOverlay
      dependencyOverlays
      dependencyOverlay;
    default = dependencyOverlay;
    dependencies = dependencyOverlays;
  };
}
