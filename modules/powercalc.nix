{ hass, config, types, lib, ... }: with lib; let
  cfg = config.powercalc;
  getEntity = entity_id: if entity_id ? object_id then hass.${entity_id.domain}."${entity_id.object_id}" else (throw "unknown entity ${entity_id}");
  powercalcSensorID = {
    power = entity: "${entity.object_id}_power";
    energy = entity: "${entity.object_id}_energy";
  };
  powercalcSensor = mapAttrs (_: sensor_id:
    entity: hass.sensor."${sensor_id entity}"
  ) powercalcSensorID;
  hasPowercalcConfig = entity: if (
    entity ? powercalc
  ) && (powercalcConfig entity) != null then true else false;
  powercalcConfig = entity: entity.powercalc or { };
  mapPowercalcCreate = {
    entity ? null
  , powercalc ? powercalcConfig entity
  , name ? entity.object_id.name or null
  }@args: let
    on = powercalc.on or { };
    powercalc_power = if on.wled or { } != { } then {
      inherit (on) wled;
    } else if on.linear or { } != { } then {
      inherit (on) linear;
    } else if on.fixed or { } != { } then {
      inherit (on) fixed;
    } else if on ? model then {
      inherit (on) manufacturer model;
    } else assert on == { }; { };
  in {
    ${if powercalc ? entity_id || (args ? entity && entity != null) then "entity_id" else null} = powercalc.entity_id or entity;
    ${if powercalc ? off then "standby_power" else null} = powercalc.off;
    ${if powercalc ? power_sensor_id then "power_sensor_id" else null} = powercalc.power_sensor_id;
    ${if powercalc ? energy_sensor_id then "energy_sensor_id" else null} = powercalc.energy_sensor_id;
    ${if powercalc ? group then "create_group" else null} = powercalc.create_group or name;
    ${if powercalc ? group then "entities" else null} = map (entity_id': let
      entity_id = if entity_id' ? object_id then hass."${entity_id'.domain}"."${entity_id'.object_id}" else entity_id';
    in if hasPowercalcConfig entity_id then mapPowercalcCreate {
        entity = getEntity entity_id;
      }
      else if isAttrs entity_id && ! isStringLike entity_id then mapPowercalcCreate {
        powercalc = entity_id;
      }
      else {
        inherit entity_id;
      }) powercalc.group;
  } // powercalc_power;
  powercalcModule = { config, name, types, ... }: let
    hasEntity = config.entity != null;
    entity = config.entity.get { };
  in {
    options = with types; {
      enable = mkEnableOption "powercalc sensor" // {
        default = config.settings.powercalc != null;
      };
      entity = mkOption {
        type = nullOr hassRefEntity;
      };
      entity_object_id = mkOption {
        type = objectId;
        default = name;
      };
      power = {
        create = mkEnableOption "power entity" // {
          default = config.settings.powercalc.create_power_sensor or true && ! (config.settings.powercalc ? energy_sensor_id);
        };
        object_id = mkOption {
          type = objectId;
          default = "${config.entity_object_id.name} Power";
        };
        friendly_name = mkOption {
          type = string;
          default = config.power.object_id.name;
        };
      };
      energy = {
        create = mkEnableOption "energy entity" // {
          default = config.settings.powercalc.create_energy_sensor or true && ! (config.settings.powercalc ? energy_sensor_id);
        };
        object_id = mkOption {
          type = objectId;
          default = "${config.entity_object_id.name} Energy";
        };
        friendly_name = mkOption {
          type = string;
          default = config.energy.object_id.name;
        };
      };
      settings = {
        powercalc = mkOption {
          # TODO: make this attrsOf? but causes problems when powercalc sensors refer to other sensors though...
          type = nullOr (lazyAttrsOf unspecified);
          default = { };
        };
        create = mkOption {
          type = attrs;
        };
        power = mkOption {
          type = attrs;
        };
        energy = mkOption {
          type = attrs;
        };
        sensors = mkOption {
          type = attrsOf attrs;
        };
      };
    };
    config = {
      entity_object_id = mkIf hasEntity (mkDefault
        entity.object_id.name
      );
      energy.friendly_name = mkIf (hasEntity && entity.friendly_name != null) (mkDefault
        "${entity.friendly_name} Energy"
      );
      power.friendly_name = mkIf (hasEntity && entity.friendly_name != null) (mkDefault
        "${entity.friendly_name} Power"
      );
      settings = {
        powercalc = mkIf hasEntity entity.powercalc or { };
        create = mapPowercalcCreate {
          entity = config.entity;
          inherit (config.settings) powercalc;
          name = config.entity_object_id.name;
        };
        power = rec {
          object_id = config.power.object_id.object_id;
          name = config.power.object_id.name;
          friendly_name = config.power.friendly_name;
          customize = optionalAttrs (name != friendly_name) {
            inherit friendly_name;
          };
          create = {
            platform = "powercalc";
          } // config.settings.create;
        };
        energy = rec {
          object_id = config.energy.object_id.object_id;
          name = config.energy.object_id.name;
          friendly_name = config.energy.friendly_name;
          #friendly_name = "${if entity.friendly_name or null != null then entity.friendly_name else entity.name} Energy";
          customize = optionalAttrs (name != friendly_name) {
            inherit friendly_name;
          };
        };
        sensors = {
          "${config.power.object_id}" = mkIf config.power.create config.settings.power;
          "${config.energy.object_id}" = mkIf config.energy.create config.settings.energy;
        };
      };
    };
  };
in {
  options.powercalc = with types; {
    entities = mkOption {
      #type = listOf hassRefEntity;
      #default = [ ];
      type = let
        hassRefLike = either stringlike hassObject;
        powercalcEntityType = submoduleWith {
          modules = [ powercalcModule ];
          inherit (config.lib) specialArgs;
        };
        # TODO: include domain here!!!
        getObjectId = entity: toString (coalesce [
          entity.object_id.object_id or null
          entity.object_id or null
          entity
        ]);
        getContent = value: if value._type or null == "if" then value.content else value;
        mapIf = mkContent: value: if value._type or null == "if" then value // {
          content = mkContent value.content;
        } else mkContent value;
        mapEntityToPowercalc = entity: {
          entity = mkOptionDefault entity;
        };
        conv = mapListToAttrs (entity: let
          object_id =
            # fast-track the mkIf in case the content does not evaluate...
            if entity._type or null == "if" && !entity.condition then "mkIf(false)"
            else getObjectId (getContent entity);
        in nameValuePair object_id (mapIf mapEntityToPowercalc entity));
      in coercedTo (listOf hassRefLike) conv (attrsOf powercalcEntityType);
      default = { };
    };
  };
  config = {
    entities.sensor = mkMerge (mapAttrsToList (_: e: mkIf e.enable e.settings.sensors) cfg.entities);
    _module.args = {
      powercalc = {
        sensorID = powercalcSensorID;
        sensor = powercalcSensor;
      };
    };
  };
}
