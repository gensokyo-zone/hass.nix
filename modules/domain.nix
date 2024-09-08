let
  domainModule = { entities, meta, name, config, types, lib, ... }: with lib; {
    options = with types; {
      name = mkOption {
        type = str;
        default = name;
      };
      implicitDomain = mkOption {
        type = bool;
        default = false;
      };
      freeform = mkOption {
        type = bool;
        default = true;
      };
      modules = mkOption {
        type = listOf unspecified;
        default = [ ];
      };
      classes = mkOption {
        type = attrsOf unspecified;
        default = { };
      };
      services = mkOption {
        type = attrsOf unspecified;
        default = { };
      };
      events = mkOption {
        type = attrsOf unspecified;
        default = { };
      };
      virtual = mkOption {
        type = bool;
        default = !config.entity.enable;
      };
      entity = {
        enable = mkEnableOption "represents an entity domain";
        manual = mkOption {
          type = bool;
          default = false;
          description = "implemented manually, or cannot be configured normally";
        };
        attributes = mkOption {
          type = attrsOf unspecified;
          default = { };
        };
      };
      get = mkOption {
        type = functionTo unspecified;
        default = object_id: let
          fallback = throw "${config.name}.${object_id} could not be found";
        in if config.entity.enable
          then meta.entities.${config.name}."${object_id}" or entities.${config.name}."${object_id}" or fallback
          else meta.${config.name}."${object_id}" or fallback;
      };
    };
    config = {
      modules = mkMerge [
        [ types.objectModule types.assertions ]
        (mkIf (!config.entity.manual) [ types.entityModule ])
      ];
    };
  };
in { config, types, lib, ... }: with lib; let
  cfg = config.domain;
in {
  options = with types; {
    domain = mkOption {
      type = hassAttrs {
        modules = [ domainModule ];
        freeform = false;
      };
      default = { };
    };
  };
  config.lib.types = with types; {
    domainType = enum (mapAttrsToList (_: domain: domain.name) cfg);
  };
}
