{ ... }:
final: prev:
let
  juliaEnv = prev.julia-bin.withPackages [
    "LanguageServer"
  ];
in
{
  julia-bin = juliaEnv;
}
