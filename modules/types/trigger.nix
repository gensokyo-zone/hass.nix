let
  triggerModule = { name, config, types, lib, ... }: with lib; {
    imports = [ types.settingsModule ];
    options = with types; {
      id = mkOption {
        type = nullOr str;
        default = if hasPrefix "[definition" (toString name) || name == "trigger" then null else name;
      };
    };
    config = {
      settingsConfig.nullableKeys = [ "id" ];
    };
  };
in { config, types, lib, ... }: with lib; {
  config.lib.types = with types; {
    triggerType = submoduleWith {
      modules = [ triggerModule ];
      inherit (config.lib) specialArgs;
    };
  };
}
