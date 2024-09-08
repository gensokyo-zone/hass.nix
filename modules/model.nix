{ config, types, lib, ... }: with lib; let
  entityModule = { domain, name, config, types, lib, ... }: with lib; {
    options = with types; {
      alias = mkOption {
        type = str;
        default = name;
      };
      name = mkOption {
        type = nullOr str;
        default = if name == domain then null else name;
      };
      name_prefix = mkOption {
        type = nullOr str;
        default = null;
      };
      attributes = mkOption {
        type = attrsOf unspecified;
        default = { };
      };
      settings = mkOption {
        type = json.attrs;
        default = { };
      };
    };
  };
  modelModule = { meta, name, config, types, lib, ... }: with lib; {
    options = with types; {
      object_id = mkOption {
        type = str;
        default = name;
      };
      name = mkOption {
        type = str;
      };
      entity_name = mkOption {
        type = nullOr str;
        default = null;
      };
      platform = mkOption {
        type = hassRef "platform";
      };
      entities = mkOption {
        type = domainAttrs {
          modules = [ entityModule ];
        };
        default = { };
      };
    };
  };
in {
  options = with types; {
    model = mkOption {
      type = hassAttrs {
        domain = "model";
        modules = [ modelModule ];
      };
      default = { };
    };
  };
  config.domain.model = {
    virtual = true;
  };
}
