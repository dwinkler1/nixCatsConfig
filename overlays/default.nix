{ nixpkgs, ... }@inputs:
let
  lib = nixpkgs.lib;

  pythonOverlay = import ./python.nix inputs;
  pluginsOverlay = import ./plugins.nix inputs;

  dependencyOverlays = [
    pythonOverlay
    pluginsOverlay
  ];
  dependencyOverlay = lib.composeManyExtensions dependencyOverlays;
in
{
  inherit
    pythonOverlay
    pluginsOverlay
    dependencyOverlays
    dependencyOverlay;

  # Named exports for downstream composition.
  default = dependencyOverlay;
  dependencies = dependencyOverlays;

  overlays = {
    inherit
      pythonOverlay
      pluginsOverlay
      dependencyOverlays
      dependencyOverlay;
    default = dependencyOverlay;
    dependencies = dependencyOverlays;
  };
}
