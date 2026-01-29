{ ... }:
final: prev:
let
  reqPkgs = pyPackages:
    with pyPackages; [
      numpy
    ];
in
{
  python = prev.python3.withPackages reqPkgs;
}
