{ config, types, lib, ... }: with lib; let
  cfg = config.entities.scene;
  sceneEntityModule = { name, config, types, lib, ... }: with lib; {
    imports = [ types.settingsModule ];
    options = with types; {
      entity = mkOption {
        type = hassRef null;
        default = name;
      };
    };
    config = {
      settingsConfig.ignoreKeys = [ "entity" ];
    };
  };
  sceneModule = { package, name, config, types, lib, ... }: with lib; {
    options = with types; {
      label = mkOption {
        type = str;
        default = package.label;
      };
      entities = mkOption {
        type = attrsOf sceneEntityType;
        default = { };
      };
      settings = mkOption {
        type = json.attrs;
      };
    };
    config = {
      icon = mkIf (config.settings.icon or null != null) (mkDefault config.settings.icon);
      unique_id = mkIf (config.settings.id or null != null) (mkDefault config.settings.id);
      settings = {
        id = nameid name;
        name = config.object_id.name;
        entities = mapAttrs (_: getSettings) config.entities;
      };
    };
  };
in {
  config = let
    scenes = groupBy (scene: scene.label) (attrValues cfg);
  in {
    package.manual = mapAttrs' (label: scenes: nameValuePair "scene ${label}" (map getSettings scenes)) scenes;
    domain.scene = {
      freeform = false;
      modules = [ sceneModule ];
      entity = {
        enable = true;
        manual = true;
      };
    };
    lib.types = with types; {
      sceneEntityType = submoduleWith {
        modules = [ sceneEntityModule ];
        inherit (config.lib) specialArgs;
      };
    };
  };
}
