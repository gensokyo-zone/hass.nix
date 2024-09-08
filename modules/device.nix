{ config, types, lib, ... }: with lib; let
  cfg = config.device;
  powercalcModule = { hass, device, domain, name, config, types, lib, ... }: with lib; let
  in {
    freeformType = types.json.attrs;
    options = with types; {
      power_sensor_id = mkOption {
        type = nullOr (hassRef "sensor");
        default = null;
      };
    };
  };
  entityModule = { meta, device, domain, name, config, types, lib, ... }: with lib; let
    model = device.model.get { };
    modelled = config.modelled.get { };
    modelled_name = modelled.name or (
      if config.alias == domain then null else name
    );
  in {
    options = with types; {
      area = mkOption {
        type = nullOr (hassRef "area");
        default = device.area;
      };
      alias = mkOption {
        type = str;
        default = name;
      };
      modelled.get = mkOption {
        type = functionTo unspecified;
        default = _: model.entities.${domain}.${config.alias} or null;
      };
      object_name = mkOption {
        type = str;
        default = concatStringsSep " " (
          optional (modelled.name_prefix or null != null) modelled.name_prefix
          ++ optional (device.entity_name != "") device.entity_name
          ++ optional (modelled_name != null) modelled_name
        );
      };

      domain = mkOption {
        type = str;
        default = domain;
      };
      object_id = mkOption {
        type = objectId;
        default = config.object_name;
      };
      customize = mkOption {
        type = json.attrs;
        default = { };
      };
      export = mkOption {
        type = nullOr json.attrs;
        default = null;
      };
      get = mkOption {
        type = functionTo unspecified;
        default = _: meta.domain.${domain}.get config.object_id;
      };
      __toString = mkOption {
        type = functionTo str;
        default = self: "${self.domain}.${self.object_id}";
      };
      settings = mkOption {
        type = unmerged.attrs;
      };
    };
    config = {
      settings = mkMerge [
        (mapAttrs (_: mkDefault) {
          inherit (config) area domain object_id;
        })
        {
          export = mkIf (config.export != null) (mkDefault config.export);
          customize = mapAttrs (_: mkDefault) config.customize;
          _module.args = {
            inherit device;
          };
        }
        (mkIf (modelled != null) (
          mapAttrs (_: mkOptionDefault) modelled.settings
        ))
      ];
    };
  };
  deviceModule = { name, config, hass, lib, ... }: with lib; let
    model = config.model.get { };
  in {
    options = with types; {
      id = mkOption {
        type = str;
      };
      device_id = mkOption {
        type = str;
        default = todo config.id;
      };
      object_id = mkOption {
        type = str;
        default = name;
      };
      model = mkOption {
        type = nullOr (hassRef "model");
        default = null;
      };
      area = mkOption {
        type = nullOr (hassRef "area");
        default = null;
      };
      name = mkOption {
        type = str;
        default = if model.entity_name != null then model.entity_name else name;
      };
      entity_name = mkOption {
        type = str;
        default = if model.entity_name != null then model.entity_name else config.name;
      };
      # TODO: friendly_name that auto-customizes all device entities?
      entities = mkOption {
        type = domainAttrs {
          freeform = false;
          modules = [
            entityModule
            ({ ... }: {
              config._module.args = {
                device = config;
              };
            })
          ];
        };
        default = { };
      };
      mqtt = {
        actionTrigger = mkOption {
          # TODO: move this onto the device_automation domain instead!!!
          type = functionTo /*triggerType*/ unspecified;
          default = { name }: trigger.device.mqtt.action ({
            inherit (config.entities.device_automation.${name}.modelled.get { }) subtype;
            inherit (config) device_id;
          } // optionalAttrs (config ? mqtt.unique_id) {
            inherit (config.mqtt) unique_id;
          });
        };
      };
      __toString = mkOption {
        type = functionTo str;
        default = self: self.id;
      };
    };
    config.entities = let
      entities = mapAttrs (domain:
        mapAttrs (alias: modelled: { })
      ) model.entities;
    in mkIf (config.model != null) entities;
  };
  entities = mapAttrsToList (_: device:
    mapAttrs (domain:
      mapAttrs' (_: object: nameValuePair "${object.object_id}" ({ ... }: {
        config = types.unmerged.mergeAttrs object.settings;
      }))
    ) device.entities
  ) cfg;
in {
  options = with types; {
    device = mkOption {
      type = hassAttrs {
        domain = "device";
        modules = [ deviceModule ];
      };
      default = { };
    };
  };
  config = {
    entities = mkMerge entities;
    domain.device.virtual = true;
  };
}
