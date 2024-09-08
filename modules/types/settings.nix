let
  settingsModule = { config, types, lib, ... }: with lib; {
    freeformType = mkDefault types.json.attrs;
    options = with types; {
      settings = mkOption {
        type = json.attrs;
      };
      settingsConfig = {
        ignoreKeys = mkOption {
          type = listOf str;
        };
        nullableKeys = mkOption {
          type = listOf str;
          default = [ ];
        };
        mkDefaults = mkOption {
          type = bool;
          default = true;
        };
        settings = mkOption {
          type = json.attrs;
        };
        settingsKeys = mkOption {
          type = nullOr (listOf str);
          default = null;
        };
        lazyAttrs = mkEnableOption "lazy";
      };
    };
    config = {
      settingsConfig = {
        ignoreKeys = [ "_module" "settings" "settingsConfig" ];
        settings = mkOptionDefault (
          removeAttrs config (config.settingsConfig.ignoreKeys ++ config.settingsConfig.nullableKeys)
          // mapAttrs (_: value: mkIf (value != null) value) (retainAttrs config config.settingsConfig.nullableKeys)
        );
      };
      settings = (if config.settingsConfig.settingsKeys != null then flip retainAttrs config.settingsConfig.settingsKeys else id) (
        (if config.settingsConfig.mkDefaults then mapAttrs (_: mkDefault) else id) config.settingsConfig.settings
      );
    };
  };
in { config, types, lib, ... }: with lib; {
  config.lib.types = with types; {
    inherit settingsModule;
    settingsType = submoduleWith {
      modules = [ settingsModule ];
      inherit (config.lib) specialArgs;
    };
  };
}
