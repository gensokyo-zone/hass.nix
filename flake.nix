{
  inputs = {
    flakelib = {
      url = "github:flakelib/fl";
    };
    nixpkgs = { };
  };
  outputs = { self, nixpkgs, flakelib, ... }@inputs: let
    inherit (self) lib;
    nixlib = inputs.nixpkgs.lib;
  in flakelib {
    inherit inputs;
    packages = {
      sample = { mkHassPackage }: mkHassPackage {
        inherit (lib.sample) config;
      };
    };
    builders = {
      mkHassPackage = { linkFarm, writeText }: {
        pname ? "package"
      , name ? "home-assistant-${pname}"
      , passthru ? {}
      , config
      }: let
        files = nixlib.mapAttrs (name: text:
          writeText "home-assistant-${name}" text
        ) config.package.textFiles;
        filePaths = nixlib.mapAttrsToList (name: path: {
          inherit name path;
        }) files;
      in linkFarm name filePaths // passthru // files;
    };
    lib = {
      inherit nixlib;
      hass-lib = import ./lib {
        inherit (nixpkgs) lib;
        entityDomains = builtins.attrNames (import ./config/domains.nix rec {
          hass = throw "hass arg used when determining domains"; lib = hass.lib;
        });
      };
      lib = import ./lib/lib.nix {
        inherit nixlib self;
      };
      sample = lib.lib.evalModules {
        modules = lib.imports ++ [
          ./sample
        ];
        inherit (lib) specialArgs;
      };
      modules = {
        modules = ./modules;
        config = ./config;
        sample = ./sample;
        assertions = inputs.nixpkgs + "/nixos/modules/misc/assertions.nix";
      };
      imports = [
        lib.modules.modules
        lib.modules.config
        lib.modules.assertions
      ];
      specialArgs = {
        inherit (lib) hass-lib;
        hass-nix = self;
      };
    };
  };
}
