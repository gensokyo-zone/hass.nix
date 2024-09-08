let
  objectModule = { domain, name, meta, config, types, lib, ... }: with lib; {
    options = with types; {
      friendly_name = mkOption {
        type = nullOr str;
        default = config.object_id.name;
      };
      icon = mkOption {
        type = nullOr str;
        default = config.object_id.name;
      };
      unique_id = mkOption {
        type = nullOr str;
        default = null;
      };
      area = mkOption {
        type = nullOr (hassRef "area");
        default = null;
      };
      object_id = mkOption {
        type = objectId;
        default = name;
      };
      domain = mkOption {
        type = str;
        default = domain;
      };
      __toString = mkOption {
        type = functionTo str;
        default = self: "${self.domain}.${self.object_id}";
      };
      customize = mkOption {
        type = json.attrs;
        default = { };
      };
    };
    config = {
      friendly_name = mkIf (config.customize.friendly_name or null != null) config.customize.friendly_name;
      icon = mkIf (config.customize.icon or null != null) config.customize.icon;
    };
  };
in { config, types, lib, ... }: {
  config.lib = {
    types = with types; {
      inherit objectModule;
      hassObject = lib.mkOptionType rec {
        name = "hass-object";
        description = name;
        descriptionClass = "noun";
        check = v: v ? object_id;
        inherit (types.json.attrs) merge;
      };
    };
  };
}
