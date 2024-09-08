let
  actionModule = { config, types, lib, ... }: with lib; {
    imports = [ types.settingsModule ];
  };
  conditionalActionsModule = { config, types, lib, ... }: with lib; {
    options = with types; {
      conditions = mkOption {
        type = toListOf conditionType;
        default = [ ];
      };
      sequence = mkOption {
        type = toListOf actionType;
        default = [ ];
      };
    };
    config = {
    };
  };
in { config, types, lib, ... }: with lib; {
  config.lib.types = with types; {
    actionType = submoduleWith {
      modules = [ actionModule ];
      inherit (config.lib) specialArgs;
    };
    conditionalActionsType = submoduleWith {
      modules = [ conditionalActionsModule ];
      inherit (config.lib) specialArgs;
    };
  };
}
