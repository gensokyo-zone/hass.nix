{ config, lib, ... }: with lib; {
  imports = [
    ./types
    ./area.nix
    ./automation.nix
    ./beacon.nix
    ./device.nix
    ./domain.nix
    ./platform.nix
    ./espresense.nix
    ./model.nix
    ./scene.nix
    ./script.nix
    ./entities.nix
    ./powercalc.nix
    ./package.nix
  ];

  options = with types; {
    lib = mkOption {
      type = lazyAttrsOf (lazyAttrsOf unspecified);
      default = { };
    };
  };
  config = {
    lib.specialArgs = {
      meta = config;
    };
    _module = {
      args = config.lib.specialArgs;
    };
  };
}
