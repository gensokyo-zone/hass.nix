let
  scriptModule = { package, name, config, types, lib, ... }: with lib; {
    options = with types; {
      label = mkOption {
        type = str;
        default = package.label;
      };
      sequence = mkOption {
        type = toListOf actionType;
        default = [ ];
      };

      settings = mkOption {
        type = json.attrs;
      };
    };
    config = {
      icon = mkIf (config.settings.icon or null != null) (mkDefault config.settings.icon);
      friendly_name = mkIf (config.settings.alias or null != null) (mkDefault config.settings.alias);
      settings = {
        sequence = map getSettings config.sequence;
        alias = mkOptionDefault config.object_id.name;
      };
    };
  };
in { config, lib, ... }: with lib; let
  cfg = config.entities.script;
in {
  config = let
    scripts = groupBy (script: script.label) (attrValues cfg);
  in {
    package.manual = mapAttrs' (label: scripts: nameValuePair "script ${label}" (
      mapListToAttrs (script: nameValuePair "${script.object_id}" (getSettings script)) scripts
    )) scripts;
    domain.script = {
      freeform = false;
      modules = [ scriptModule ];
      entity = {
        enable = true;
        manual = true;
      };
    };
  };
}
