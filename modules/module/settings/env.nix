{
  config,
  pkgs,
  lib,
  ...
}:
{
  config.env = lib.mkMerge [
    (lib.mkIf (config.cats.r or false) {
      R_LIBS_USER = "./.Rlibs";
    })
    (lib.mkIf (config.cats.python or false) {
      UV_PYTHON_DOWNLOADS = "never";
      UV_PYTHON = pkgs.python.interpreter;
    })
    (lib.mkIf (config.cats.test or false) {
      TESTVAR = "It worked!";
    })
  ];

  config.envDefault = lib.mkIf (config.cats.test or false) {
    TESTVAR2 = "It worked again!";
  };

  config.settings.environmentVariables = lib.mkMerge [
    (lib.mkIf (config.cats.r or false) {
      r = {
        R_LIBS_USER = "./.Rlibs";
      };
    })
    (lib.mkIf (config.cats.python or false) {
      python = {
        UV_PYTHON_DOWNLOADS = "never";
        UV_PYTHON = pkgs.python.interpreter;
      };
    })
    (lib.mkIf (config.cats.test or false) {
      test = {
        TESTVAR = "It worked!";
      };
    })
  ];
}
