{ nixpkgs, ... }@inputs:
let
  lib = nixpkgs.lib;

  rOverlay = import ./r.nix inputs;
  pythonOverlay = import ./python.nix inputs;
  pluginsOverlay = import ./plugins.nix inputs;

  dependencyOverlays = [
    rOverlay
    pythonOverlay
    pluginsOverlay
  ];
  dependencyOverlay = lib.composeManyExtensions dependencyOverlays;
in
{
  inherit
    rOverlay
    pythonOverlay
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
      pluginsOverlay
      dependencyOverlays
      dependencyOverlay;
    default = dependencyOverlay;
    dependencies = dependencyOverlays;
  };
}
