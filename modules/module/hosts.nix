{
  config,
  lib,
  pkgs,
  wlib,
  ...
}:
let
  make_wrapper = wrapper_config: (import wlib.modules.makeWrapper).wrap {
    inherit wlib;
    inherit (pkgs) callPackage;
    config = wrapper_config;
  };
  host_entry =
    name: host_cfg: {
      name = name;
      nvim_host = {
        enable = host_cfg.enable;
        disabled_variable = "loaded_${name}_provider";
        enabled_variable = "${name}_host_prog";
        var_path = host_cfg.path.value;
      };
      wrapper =
        if host_cfg.enable then
          make_wrapper {
            package = host_cfg.path.value;
            binName = "${config.binName}-${name}";
            addFlag = host_cfg.path.args;
          }
        else
          null;
    };
  config_hosts = [
    (host_entry "g" {
      enable = true;
      path = {
        value = pkgs.neovide;
        args = [
          "--add-flags"
          "--neovim-bin ${config.binName}"
        ];
      };
    })
    (host_entry "m" {
      enable = false;
      path = {
        value = pkgs.uv;
        args = [
          "--add-flags"
          "run marimo edit"
        ];
      };
    })
    (host_entry "jl" {
      enable = true;
      path = {
        value = pkgs.julia-bin;
        args = [
          "--add-flags"
          "--project=@."
        ];
      };
    })
    (host_entry "r" {
      enable = true;
      path = {
        value = pkgs.rWrapper;
        args = [
          "--add-flags"
          "--no-save --no-restore"
        ];
      };
    })
  ];
in
{
  config.hosts =
    builtins.listToAttrs (
      [
        {
          name = "node";
          value = { nvim-host.enable = true; };
        }
        {
          name = "perl";
          value = { nvim-host.enable = true; };
        }
        {
          name = "python3";
          value = { nvim-host.enable = true; };
        }
        {
          name = "ruby";
          value = { nvim-host.enable = true; };
        }
        {
          name = "neovide";
          value = { nvim-host.enable = true; };
        }
      ]
      ++ map (
        entry: {
          name = entry.name;
          value = {
            nvim-host = entry.nvim_host;
            wrapper = entry.wrapper;
          };
        }
      ) config_hosts
    );
}
