# See https://github.com/nix-community/nix-on-droid/issues/469#issuecomment-3178156202
{ config, lib, ... }:
let
  cfg = config.environment;
in
{
  options = {
    environment.systemPackages = lib.mkOption {
      default = [ ];
      description = "Nix-on-droid uses `packages`.";
    };
    environment.variables = lib.mkOption {
      default = { };
      description = "Nix-on-droid uses `sessionVariables`.";
    };
  };

  config = {
    environment.packages = cfg.systemPackages;
    environment.sessionVariables = cfg.variables;
  };
}
