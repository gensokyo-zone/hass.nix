let
  conditionModule = { config, types, lib, ... }: with lib; {
    freeformType = types.json.attrs;
    options = with types; {
    };
    config = {
    };
  };
in { config, types, lib, ... }: with lib; {
  config.lib.types = with types; {
    conditionType = submoduleWith {
      modules = [ conditionModule ];
      inherit (config.lib) specialArgs;
    };
  };
}
