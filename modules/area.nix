{ config, types, lib, ... }: with lib; let
  areaModule = { meta, domain, name, config, hass, lib, ... }: with lib; {
    options = with types; {
      object_id = mkOption {
        type = objectId;
        default = name;
      };
      friendly_name = mkOption {
        type = nullOr str;
        default = config.customize.friendly_name or config.object_id.name;
        readOnly = true;
      };
      domain = mkOption {
        type = str;
        default = domain;
      };
      zone = mkOption {
        type = nullOr (hassRef "zone");
        default = meta.zone.${name} or null;
      };
    };
  };
in {
  options = with types; {
    area = mkOption {
      type = hassAttrs {
        domain = "area";
        modules = [ areaModule ];
      };
      default = {};
    };
  };
  config = {
    domain.area.virtual = true;
  };
}
