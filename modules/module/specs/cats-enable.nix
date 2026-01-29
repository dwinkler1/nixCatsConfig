{ config, lib, ... }:
{
  # Centralize category-driven enabling of specs.
  # Runs early so later specMaps (plugin deps, autoconfig, etc.) can follow.
  config.specMaps = lib.mkOrder 200 [
    {
      name = "CATS_ENABLE";
      data =
        list:
        map (
          v:
          if v.type == "spec" || v.type == "parent" then
            let
              specName =
                if v.name == null then
                  null
                else if lib.hasSuffix "-lazy" v.name then
                  lib.removeSuffix "-lazy" v.name
                else
                  v.name;
              catEnabled =
                if specName != null && builtins.hasAttr specName config.cats then
                  config.cats.${specName}
                else
                  true;
            in
            v
            // {
              value = v.value // {
                enable = if v.value ? enable then v.value.enable else catEnabled;
              };
            }
          else
            v
        ) list;
    }
  ];
}
